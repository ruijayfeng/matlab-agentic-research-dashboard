function context = buildContext(tickers, candlesBySymbol, portfolio)
%BUILDCONTEXT Build structured multi-asset AI analysis context.
    arguments
        tickers table
        candlesBySymbol struct
        portfolio table = table()
    end

    targetSymbols = ["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"];
    symbols = localAvailableSymbols(targetSymbols, candlesBySymbol);
    marketSnapshot = localMarketSnapshot(tickers, symbols);
    technicalState = localTechnicalState(candlesBySymbol, symbols);
    [returnMatrix, returnSymbols] = localReturnMatrix(candlesBySymbol, symbols);
    correlation = localCorrelation(returnMatrix, returnSymbols);
    riskContributions = localRiskContributions(portfolio, technicalState);
    signals = localSignals(riskContributions, technicalState, correlation);
    strategyScores = crypto.analysis.buildStrategyScores(struct( ...
        "Universe", symbols, ...
        "TechnicalState", technicalState, ...
        "Correlation", correlation, ...
        "RiskContributions", riskContributions), candlesBySymbol);

    context = struct();
    context.Version = "ai-analysis-context-v1";
    context.GeneratedAt = datetime("now", "TimeZone", "Asia/Shanghai");
    context.Universe = symbols;
    context.MarketSnapshot = marketSnapshot;
    context.TechnicalState = technicalState;
    context.Portfolio = portfolio;
    context.Correlation = correlation;
    context.RiskContributions = riskContributions;
    context.StrategyScores = strategyScores;
    context.Signals = signals;
    context.LLMPayload = localPayload(context);
end

function symbols = localAvailableSymbols(targetSymbols, candlesBySymbol)
    symbols = strings(0, 1);
    for idx = 1:numel(targetSymbols)
        field = matlab.lang.makeValidName(char(targetSymbols(idx)));
        if isfield(candlesBySymbol, field)
            symbols(end + 1, 1) = targetSymbols(idx); %#ok<AGROW>
        end
    end
end

function snapshot = localMarketSnapshot(tickers, symbols)
    names = {'Symbol', 'LastPrice', 'PriceChangePercent', 'QuoteVolume', 'HighPrice', 'LowPrice'};
    snapshot = table(strings(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), ...
        'VariableNames', names);
    if isempty(tickers) || height(tickers) == 0
        return
    end
    for idx = 1:numel(symbols)
        row = find(strcmp(string(tickers.Symbol), symbols(idx)), 1, "first");
        if isempty(row)
            continue
        end
        values = table(symbols(idx), tickers.LastPrice(row), tickers.PriceChangePercent(row), ...
            localColumnValue(tickers, "QuoteVolume", row), localColumnValue(tickers, "HighPrice", row), ...
            localColumnValue(tickers, "LowPrice", row), 'VariableNames', names);
        snapshot = [snapshot; values]; %#ok<AGROW>
    end
end

function value = localColumnValue(tbl, columnName, row)
    if ismember(columnName, string(tbl.Properties.VariableNames))
        value = tbl.(columnName)(row);
    else
        value = NaN;
    end
end

function technical = localTechnicalState(candlesBySymbol, symbols)
    technical = table(strings(0, 1), strings(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), ...
        zeros(0, 1), zeros(0, 1), zeros(0, 1), false(0, 1), ...
        'VariableNames', {'Symbol', 'AssetClass', 'LastClose', 'Return1D', 'Return20D', ...
        'Volatility20', 'VolatilityPercentile', 'MaxDrawdown', 'HasRecentAnomaly'});
    for idx = 1:numel(symbols)
        symbol = symbols(idx);
        candles = candlesBySymbol.(matlab.lang.makeValidName(char(symbol)));
        if isempty(candles) || height(candles) == 0
            continue
        end
        close = candles.Close;
        returns = [NaN; diff(close) ./ close(1:end-1)];
        lastClose = close(end);
        return1D = localWindowReturn(close, 2);
        return20D = localWindowReturn(close, 21);
        vol20 = std(returns(max(1, end - 19):end), "omitnan") * sqrt(252);
        rollingVol = localRollingVolatility(returns, 20);
        volPct = mean(rollingVol <= vol20, "omitnan");
        maxDrawdown = min(close ./ cummax(close) - 1);
        hasRecentAnomaly = ismember("IsReturnAnomaly", string(candles.Properties.VariableNames)) && ...
            any(candles.IsReturnAnomaly(max(1, height(candles) - 9):end));
        technical = [technical; table(symbol, localAssetClass(symbol), lastClose, return1D, return20D, ...
            vol20, volPct, maxDrawdown, hasRecentAnomaly, 'VariableNames', technical.Properties.VariableNames)]; %#ok<AGROW>
    end
end

function value = localWindowReturn(close, windowLength)
    if numel(close) < windowLength || close(end - windowLength + 1) == 0
        value = NaN;
    else
        value = close(end) / close(end - windowLength + 1) - 1;
    end
end

function rollingVol = localRollingVolatility(returns, lookback)
    rollingVol = NaN(size(returns));
    for idx = lookback:numel(returns)
        rollingVol(idx) = std(returns(idx - lookback + 1:idx), "omitnan") * sqrt(252);
    end
end

function assetClass = localAssetClass(symbol)
    switch string(symbol)
        case {"BTCUSDT", "ETHUSDT", "SOLUSDT"}
            assetClass = "Crypto";
        case {"SPY", "QQQ"}
            assetClass = "US Equity";
        case "GLD"
            assetClass = "Commodity";
        otherwise
            assetClass = "Unknown";
    end
end

function [returnMatrix, symbols] = localReturnMatrix(candlesBySymbol, requestedSymbols)
    series = {};
    symbols = strings(0, 1);
    minLength = inf;
    for idx = 1:numel(requestedSymbols)
        symbol = requestedSymbols(idx);
        candles = candlesBySymbol.(matlab.lang.makeValidName(char(symbol)));
        close = candles.Close;
        if numel(close) < 3
            continue
        end
        returns = diff(close) ./ close(1:end-1);
        series{end + 1} = returns(:); %#ok<AGROW>
        symbols(end + 1, 1) = symbol; %#ok<AGROW>
        minLength = min(minLength, numel(returns));
    end
    if isempty(series)
        returnMatrix = zeros(0, 0);
        return
    end
    returnMatrix = NaN(minLength, numel(series));
    for idx = 1:numel(series)
        values = series{idx};
        returnMatrix(:, idx) = values(end - minLength + 1:end);
    end
end

function correlation = localCorrelation(returnMatrix, symbols)
    if isempty(returnMatrix) || size(returnMatrix, 2) == 0
        matrix = table();
        avgCorrelation = NaN;
    else
        values = corrcoef(returnMatrix, "Rows", "pairwise");
        matrix = array2table(values, 'VariableNames', cellstr(symbols), 'RowNames', cellstr(symbols));
        upperMask = triu(true(size(values)), 1);
        avgCorrelation = mean(values(upperMask), "omitnan");
    end
    correlation = struct("Symbols", symbols, "Matrix", matrix, "AverageCorrelation", avgCorrelation);
end

function risk = localRiskContributions(portfolio, technical)
    risk = table(strings(0, 1), strings(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), ...
        'VariableNames', {'Symbol', 'AssetClass', 'Allocation', 'Volatility20', 'RiskScore', 'RiskContribution'});
    if isempty(portfolio) || height(portfolio) == 0
        return
    end
    for idx = 1:height(portfolio)
        symbol = string(portfolio.Symbol(idx));
        if symbol == "USDT"
            continue
        end
        techIdx = find(strcmp(string(technical.Symbol), symbol), 1, "first");
        if isempty(techIdx)
            vol = 0;
            assetClass = string(portfolio.AssetClass(idx));
        else
            vol = technical.Volatility20(techIdx);
            assetClass = technical.AssetClass(techIdx);
        end
        allocation = localColumnValue(portfolio, "Allocation", idx);
        score = max(allocation, 0) * max(vol, 0);
        risk = [risk; table(symbol, assetClass, allocation, vol, score, 0, 'VariableNames', risk.Properties.VariableNames)]; %#ok<AGROW>
    end
    totalScore = sum(risk.RiskScore, "omitnan");
    if totalScore > 0
        risk.RiskContribution = risk.RiskScore ./ totalScore;
    end
    risk = sortrows(risk, "RiskContribution", "descend");
end

function signals = localSignals(risk, technical, correlation)
    signals = strings(0, 1);
    if ~isempty(risk) && height(risk) > 0
        if max(risk.Allocation, [], "omitnan") >= 0.5
            signals(end + 1, 1) = "ConcentrationRisk";
        end
        cryptoRows = strcmp(risk.AssetClass, "Crypto");
        if sum(risk.RiskContribution(cryptoRows), "omitnan") >= 0.65
            signals(end + 1, 1) = "CryptoRiskDominant";
        end
    end
    if ~isempty(technical) && height(technical) > 0
        if any(technical.VolatilityPercentile >= 0.8 | technical.HasRecentAnomaly)
            signals(end + 1, 1) = "VolatilityWatch";
        end
        cryptoRows = strcmp(technical.AssetClass, "Crypto");
        equityRows = strcmp(technical.AssetClass, "US Equity");
        if any(cryptoRows) && any(equityRows)
            cryptoReturn = mean(technical.Return20D(cryptoRows), "omitnan");
            equityReturn = mean(technical.Return20D(equityRows), "omitnan");
            if cryptoReturn > 0 && equityReturn > 0
                signals(end + 1, 1) = "RiskOnTilt";
            end
        end
    end
    if ~isnan(correlation.AverageCorrelation) && correlation.AverageCorrelation >= 0.65
        signals(end + 1, 1) = "HighCrossAssetCorrelation";
    end
    signals = unique(signals, "stable");
end

function payload = localPayload(context)
    payload = struct();
    payload.version = context.Version;
    payload.universe = context.Universe;
    payload.marketSnapshot = localTablePayload(context.MarketSnapshot);
    payload.technicalState = localTablePayload(context.TechnicalState);
    payload.portfolio = localTablePayload(context.Portfolio);
    payload.riskContributions = localTablePayload(context.RiskContributions);
    payload.strategyScores = localTablePayload(context.StrategyScores);
    payload.signals = context.Signals;
    payload.averageCorrelation = context.Correlation.AverageCorrelation;
end

function rows = localTablePayload(tbl)
    rows = struct([]);
    if isempty(tbl) || height(tbl) == 0
        return
    end
    names = string(tbl.Properties.VariableNames);
    for rowIdx = 1:height(tbl)
        row = struct();
        for colIdx = 1:numel(names)
            fieldName = char(names(colIdx));
            row.(fieldName) = tbl.(fieldName)(rowIdx);
        end
        rows = [rows; row]; %#ok<AGROW>
    end
end
