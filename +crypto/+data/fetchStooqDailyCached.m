function candles = fetchStooqDailyCached(symbol, maxAgeHours)
%FETCHSTOOQDAILYCACHED Read Stooq daily candles with local caching.
    arguments
        symbol (1,1) string
        maxAgeHours (1,1) double {mustBePositive} = 18
    end

    cacheFile = localCacheFile(symbol);
    if isfile(cacheFile) && localCacheAgeHours(cacheFile) <= maxAgeHours
        candles = readtable(cacheFile);
        candles = localNormalizeCachedCandles(candles);
        return
    end

    candles = crypto.data.fetchStooqDaily(symbol);
    cacheDir = fileparts(cacheFile);
    if ~isfolder(cacheDir)
        mkdir(cacheDir);
    end
    writetable(candles, cacheFile);
end

function cacheFile = localCacheFile(symbol)
    fileName = char(upper(string(symbol)) + ".csv");
    cacheFile = fullfile(pwd, "cache", "stooq", fileName);
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
