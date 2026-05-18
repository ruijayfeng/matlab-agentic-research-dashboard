function candles = fetchExternalDailyCached(symbol, maxAgeHours)
%FETCHEXTERNALDAILYCACHED Fetch daily data with no-key source and cached fallbacks.
    arguments
        symbol (1,1) string
        maxAgeHours (1,1) double {mustBePositive} = 18
    end

    errors = strings(0, 1);

    try
        candles = crypto.data.fetchStooqDailyCached(symbol, maxAgeHours);
        return
    catch err
        errors(end + 1, 1) = "Stooq: " + string(err.message);
    end

    try
        candles = crypto.data.fetchFmpDailyCached(symbol, crypto.config.getApiKey("FMP"), 720);
        return
    catch err
        errors(end + 1, 1) = "FMP: " + string(err.message);
    end

    try
        candles = crypto.data.fetchAlphaVantageDailyCached(symbol, crypto.config.getApiKey("ALPHAVANTAGE"), 720);
        return
    catch err
        errors(end + 1, 1) = "Alpha Vantage: " + string(err.message);
    end

    error("crypto:data:ExternalDailyUnavailable", "No external daily data for %s. %s", symbol, strjoin(errors, " | "));
end
