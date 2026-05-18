function candles = fetchCandles(symbol, interval, limit)
%FETCHCANDLES Dispatch candle requests by active asset data source.
    arguments
        symbol (1,1) string
        interval (1,1) string = "1h"
        limit (1,1) double {mustBeInteger, mustBePositive} = 200
    end

    asset = crypto.assets.rowForSymbol(symbol);
    switch string(asset.DataSource)
        case "Binance"
            candles = crypto.data.fetchKlines(symbol, interval, limit);
        case "AlphaVantage"
            if interval ~= "1d"
                warning("crypto:data:DailyOnly", "%s uses Alpha Vantage daily candles; interval %s is treated as 1d.", symbol, interval);
            end
            candles = crypto.data.fetchAlphaVantageDailyCached(symbol, crypto.config.getApiKey("ALPHAVANTAGE"), 18);
        case "FMP"
            if interval ~= "1d"
                warning("crypto:data:DailyOnly", "%s uses FMP daily candles; interval %s is treated as 1d.", symbol, interval);
            end
            candles = crypto.data.fetchFmpDailyCached(symbol, crypto.config.getApiKey("FMP"), 18);
        case "Stooq"
            candles = crypto.data.fetchExternalDailyCached(symbol, 18);
            if height(candles) > limit
                candles = candles(height(candles) - limit + 1:end, :);
            end
        otherwise
            error("crypto:data:UnsupportedCandleSource", "No candle adapter for %s (%s).", symbol, asset.DataSource);
    end
end
