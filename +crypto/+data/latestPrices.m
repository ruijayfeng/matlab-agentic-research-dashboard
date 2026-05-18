function prices = latestPrices(assetRows)
%LATESTPRICES Fetch latest prices for live assets by data source.
    prices = table(strings(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), ...
        'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});

    if isempty(assetRows) || height(assetRows) == 0
        return
    end
    if ismember("IsLive", string(assetRows.Properties.VariableNames))
        hasAlphaVantage = strlength(crypto.config.getApiKey("ALPHAVANTAGE")) > 0;
        hasFmp = strlength(crypto.config.getApiKey("FMP")) > 0;
        rows = assetRows.IsLive | ...
            strcmp(assetRows.DataSource, "Stooq") | ...
            (hasFmp & strcmp(assetRows.DataSource, "FMP")) | ...
            (hasAlphaVantage & strcmp(assetRows.DataSource, "AlphaVantage"));
        assetRows = assetRows(rows, :);
    end

    binanceRows = assetRows(strcmp(assetRows.DataSource, "Binance"), :);
    if height(binanceRows) > 0
        prices = [prices; crypto.data.fetch24hTickers(reshape(binanceRows.Symbol, 1, []))];
    end

    syntheticRows = assetRows(strcmp(assetRows.DataSource, "Synthetic"), :);
    for idx = 1:height(syntheticRows)
        prices = [prices; table(syntheticRows.Symbol(idx), 1, 0, 0, 0, 1, 1, ...
            'VariableNames', prices.Properties.VariableNames)]; %#ok<AGROW>
    end

    alphaRows = assetRows(strcmp(assetRows.DataSource, "AlphaVantage"), :);
    apiKey = crypto.config.getApiKey("ALPHAVANTAGE");
    for idx = 1:height(alphaRows)
        try
            if idx > 1
                pause(1.1);
            end
            daily = crypto.data.fetchAlphaVantageDailyCached(alphaRows.Symbol(idx), apiKey, 18);
            last = daily(end, :);
            prevClose = daily.Close(max(1, height(daily) - 1));
            changePct = (last.Close - prevClose) / prevClose * 100;
            prices = [prices; table(alphaRows.Symbol(idx), last.Close, changePct, last.Volume, last.QuoteVolume, last.High, last.Low, ...
                'VariableNames', prices.Properties.VariableNames)]; %#ok<AGROW>
        catch
            % Free Alpha Vantage keys are rate-limited; keep crypto dashboard usable.
        end
    end

    fmpRows = assetRows(strcmp(assetRows.DataSource, "FMP"), :);
    fmpKey = crypto.config.getApiKey("FMP");
    for idx = 1:height(fmpRows)
        try
            daily = crypto.data.fetchFmpDailyCached(fmpRows.Symbol(idx), fmpKey, 18);
            last = daily(end, :);
            prevClose = daily.Close(max(1, height(daily) - 1));
            changePct = (last.Close - prevClose) / prevClose * 100;
            prices = [prices; table(fmpRows.Symbol(idx), last.Close, changePct, last.Volume, last.QuoteVolume, last.High, last.Low, ...
                'VariableNames', prices.Properties.VariableNames)]; %#ok<AGROW>
        catch
            % Keep dashboard usable if the optional FMP source is unavailable.
        end
    end

    stooqRows = assetRows(strcmp(assetRows.DataSource, "Stooq"), :);
    for idx = 1:height(stooqRows)
        try
            daily = crypto.data.fetchExternalDailyCached(stooqRows.Symbol(idx), 18);
            last = daily(end, :);
            prevClose = daily.Close(max(1, height(daily) - 1));
            changePct = (last.Close - prevClose) / prevClose * 100;
            prices = [prices; table(stooqRows.Symbol(idx), last.Close, changePct, last.Volume, last.QuoteVolume, last.High, last.Low, ...
                'VariableNames', prices.Properties.VariableNames)]; %#ok<AGROW>
        catch
            % Keep dashboard usable if optional Stooq data is unavailable.
        end
    end
end
