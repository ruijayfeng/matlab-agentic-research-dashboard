function candles = fetchStooqDaily(symbol)
%FETCHSTOOQDAILY Fetch daily OHLCV data from Stooq CSV endpoint.
    arguments
        symbol (1,1) string
    end

    stooqSymbol = localStooqSymbol(symbol);
    url = "https://stooq.com/q/d/l/";
    tempFile = [tempname ".csv"];
    cleanup = onCleanup(@() localDeleteTemp(tempFile));
    websave(tempFile, char(url), "s", char(stooqSymbol), "i", "d");
    data = readtable(tempFile);

    if isempty(data) || height(data) == 0 || ~ismember("Date", string(data.Properties.VariableNames))
        error("crypto:data:StooqFormat", "Stooq returned no daily data for %s.", symbol);
    end

    openTime = datetime(data.Date, "TimeZone", "Asia/Shanghai");
    closeTime = openTime + days(1) - seconds(1);
    candles = table(openTime, double(data.Open), double(data.High), double(data.Low), double(data.Close), double(data.Volume), closeTime, double(data.Volume) .* double(data.Close), zeros(height(data), 1), ...
        'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume', 'CloseTime', 'QuoteVolume', 'TradeCount'});
    candles = sortrows(candles, "OpenTime");
end

function localDeleteTemp(tempFile)
    if isfile(tempFile)
        delete(tempFile);
    end
end

function stooqSymbol = localStooqSymbol(symbol)
    switch upper(string(symbol))
        case {"SPY", "QQQ", "GLD"}
            stooqSymbol = lower(string(symbol)) + ".us";
        otherwise
            stooqSymbol = lower(string(symbol));
    end
end
