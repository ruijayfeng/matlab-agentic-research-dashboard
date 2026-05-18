function scores = buildStrategyScores(context, candlesBySymbol)
%BUILDSTRATEGYSCORES Create a multi-strategy scorecard for each asset.
    arguments
        context struct
        candlesBySymbol struct
    end

    symbols = string(context.Universe);
    scores = table(strings(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), strings(0, 1), ...
        'VariableNames', {'Symbol', 'PriceActionScore', 'TrendScore', 'MeanReversionScore', 'CrossAssetScore', 'PortfolioImpactScore', 'ValuationScore', 'CompositeScore', 'CompositeView'});
    for idx = 1:numel(symbols)
        symbol = symbols(idx);
        field = matlab.lang.makeValidName(char(symbol));
        if ~isfield(candlesBySymbol, field)
            continue
        end
        candles = candlesBySymbol.(field);
        techIdx = find(strcmp(string(context.TechnicalState.Symbol), symbol), 1, "first");
        riskIdx = find(strcmp(string(context.RiskContributions.Symbol), symbol), 1, "first");
        priceAction = localPriceActionScore(candles);
        trendScore = localTrendScore(candles);
        meanReversion = localMeanReversionScore(candles);
        crossAsset = localCrossAssetScore(context, symbol);
        portfolioImpact = localPortfolioImpactScore(context, riskIdx);
        valuation = localValuationScore(symbol);
        composite = round(mean([priceAction, trendScore, meanReversion, crossAsset, portfolioImpact, valuation], "omitnan"));
        scores = [scores; table(symbol, priceAction, trendScore, meanReversion, crossAsset, portfolioImpact, valuation, composite, localCompositeView(composite), ...
            'VariableNames', scores.Properties.VariableNames)]; %#ok<AGROW>
    end
    scores = sortrows(scores, "CompositeScore", "descend");
end

function score = localPriceActionScore(candles)
    if isempty(candles) || height(candles) < 5
        score = 0;
        return
    end
    close = candles.Close;
    last = close(end);
    ma20 = candles.MA20(end);
    high20 = max(close(max(1, end - 19):end));
    low20 = min(close(max(1, end - 19):end));
    score = 0;
    if ~isnan(ma20)
        score = score + 25 * sign(last - ma20);
    end
    if last >= high20
        score = score + 20;
    elseif last <= low20
        score = score - 20;
    end
    if ismember("IsReturnAnomaly", string(candles.Properties.VariableNames)) && any(candles.IsReturnAnomaly(max(1, height(candles)-4):end))
        score = score - 10;
    end
    score = localClampScore(score);
end

function score = localTrendScore(candles)
    if isempty(candles) || height(candles) < 5
        score = 0;
        return
    end
    score = 0;
    if ~isnan(candles.MA20(end)) && ~isnan(candles.MA50(end))
        score = score + 20 * sign(candles.MA20(end) - candles.MA50(end));
    end
    if ~isnan(candles.MACDHistogram(end))
        score = score + 15 * sign(candles.MACDHistogram(end));
    end
    return20 = localWindowReturn(candles.Close, 21);
    if ~isnan(return20)
        score = score + 20 * sign(return20);
    end
    score = localClampScore(score);
end

function value = localWindowReturn(close, windowLength)
    if numel(close) < windowLength || close(end - windowLength + 1) == 0
        value = NaN;
    else
        value = close(end) / close(end - windowLength + 1) - 1;
    end
end

function score = localMeanReversionScore(candles)
    if isempty(candles) || height(candles) < 5
        score = 0;
        return
    end
    score = 0;
    if ~isnan(candles.RSI14(end))
        if candles.RSI14(end) >= 70
            score = score - 20;
        elseif candles.RSI14(end) <= 30
            score = score + 20;
        end
    end
    if ~isnan(candles.ReturnZScore(end))
        score = score - 10 * sign(candles.ReturnZScore(end));
    end
    score = localClampScore(score);
end

function score = localCrossAssetScore(context, symbol)
    score = 0;
    if ~isfield(context, 'Correlation') || ~isfield(context.Correlation, 'AverageCorrelation')
        return
    end
    avgCorr = context.Correlation.AverageCorrelation;
    if isnan(avgCorr)
        return
    end
    if any(strcmp(string(context.TechnicalState.Symbol), symbol))
        if avgCorr >= 0.65
            score = -15;
        else
            score = 10;
        end
    end
end

function score = localPortfolioImpactScore(context, riskIdx)
    score = 0;
    if isempty(riskIdx) || ~isfield(context, 'RiskContributions') || height(context.RiskContributions) == 0
        return
    end
    row = context.RiskContributions(riskIdx, :);
    score = localClampScore(100 * (0.6 * row.RiskContribution + 0.4 * row.Allocation));
end

function score = localValuationScore(symbol)
    switch string(symbol)
        case {"SPY", "QQQ"}
            score = -25;
        case "GLD"
            score = 0;
        otherwise
            score = 0;
    end
end

function score = localClampScore(score)
    score = max(-100, min(100, score));
end

function view = localCompositeView(score)
    if score >= 20
        view = "偏多";
    elseif score <= -20
        view = "偏空";
    else
        view = "中性";
    end
end
