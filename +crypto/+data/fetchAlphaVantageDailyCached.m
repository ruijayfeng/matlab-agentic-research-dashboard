function candles = fetchAlphaVantageDailyCached(symbol, apiKey, maxAgeHours)
%FETCHALPHAVANTAGEDAILYCACHED Read Alpha Vantage daily candles with local caching.
    arguments
        symbol (1,1) string
        apiKey (1,1) string
        maxAgeHours (1,1) double {mustBePositive} = 18
    end

    cacheFile = localCacheFile(symbol);
    if isfile(cacheFile) && localCacheAgeHours(cacheFile) <= maxAgeHours
        candles = readtable(cacheFile);
        candles = localNormalizeCachedCandles(candles);
        return
    end

    try
        candles = crypto.data.fetchAlphaVantageDaily(symbol, apiKey, "compact");
        cacheDir = fileparts(cacheFile);
        if ~isfolder(cacheDir)
            mkdir(cacheDir);
        end
        writetable(candles, cacheFile);
    catch err
        if isfile(cacheFile)
            candles = readtable(cacheFile);
            candles = localNormalizeCachedCandles(candles);
        else
            rethrow(err);
        end
    end
end

function cacheFile = localCacheFile(symbol)
    fileName = char(upper(string(symbol)) + ".csv");
    cacheFile = fullfile(pwd, "cache", "alpha_vantage", fileName);
end

function ageHours = localCacheAgeHours(cacheFile)
    info = dir(cacheFile);
    ageHours = hours(datetime("now") - datetime(info.datenum, "ConvertFrom", "datenum"));
end

function candles = localNormalizeCachedCandles(candles)
    if ~isdatetime(candles.OpenTime)
        candles.OpenTime = datetime(candles.OpenTime, "TimeZone", "Asia/Shanghai");
    end
    if ~isdatetime(candles.CloseTime)
        candles.CloseTime = datetime(candles.CloseTime, "TimeZone", "Asia/Shanghai");
    end
end
