function candles = enrichCandles(candles)
%ENRICHCANDLES Add standard technical indicator columns to a candle table.
    required = ["OpenTime", "Open", "High", "Low", "Close", "Volume"];
    missing = setdiff(required, string(candles.Properties.VariableNames));
    if ~isempty(missing)
        error("crypto:indicators:MissingColumns", "Candle table is missing: %s", strjoin(missing, ", "));
    end

    closePrices = candles.Close;
    candles.MA20 = crypto.indicators.movingAverage(closePrices, 20);
    candles.MA50 = crypto.indicators.movingAverage(closePrices, 50);
    [candles.MACD, candles.MACDSignal, candles.MACDHistogram] = crypto.indicators.macd(closePrices, 12, 26, 9);
    candles.RSI14 = crypto.indicators.rsi(closePrices, 14);
    candles.Return = [NaN; diff(closePrices) ./ closePrices(1:end-1)];

    rollingVol = NaN(height(candles), 1);
    lookback = 20;
    for idx = lookback:height(candles)
        rollingVol(idx) = std(candles.Return(idx - lookback + 1:idx), "omitnan") * sqrt(lookback);
    end
    candles.RollingVolatility = rollingVol;

    retMean = mean(candles.Return, "omitnan");
    retStd = std(candles.Return, "omitnan");
    if isnan(retStd) || retStd == 0
        candles.ReturnZScore = NaN(height(candles), 1);
        candles.IsReturnAnomaly = false(height(candles), 1);
    else
        candles.ReturnZScore = (candles.Return - retMean) ./ retStd;
        candles.IsReturnAnomaly = abs(candles.ReturnZScore) >= 2.5;
    end
end
