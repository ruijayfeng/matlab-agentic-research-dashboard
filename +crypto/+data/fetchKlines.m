function candles = fetchKlines(symbol, interval, limit)
%FETCHKLINES Fetch Binance spot K-line candles as a typed MATLAB table.
    arguments
        symbol (1,1) string
        interval (1,1) string = "1h"
        limit (1,1) double {mustBeInteger, mustBePositive} = 200
    end

    baseUrl = "https://api.binance.com/api/v3/klines";
    try
        raw = webread(char(baseUrl), 'symbol', char(upper(symbol)), 'interval', char(interval), 'limit', limit);
    catch err
        error("crypto:data:KlineFetchFailed", "Failed to fetch Binance K-lines for %s %s: %s", symbol, interval, err.message);
    end

    if isempty(raw)
        candles = localEmptyCandles();
        return
    end

    if iscell(raw)
        rows = numel(raw);
    else
        rows = size(raw, 1);
    end
    displayTimeZone = "Asia/Shanghai";
    openTime = NaT(rows, 1, "TimeZone", displayTimeZone);
    closeTime = NaT(rows, 1, "TimeZone", displayTimeZone);
    open = zeros(rows, 1);
    high = zeros(rows, 1);
    low = zeros(rows, 1);
    close = zeros(rows, 1);
    volume = zeros(rows, 1);
    quoteVolume = zeros(rows, 1);
    tradeCount = zeros(rows, 1);

    for idx = 1:rows
        row = localRow(raw, idx);
        openTime(idx) = datetime(localNumber(row, 1) / 1000, "ConvertFrom", "posixtime", "TimeZone", displayTimeZone);
        open(idx) = localNumber(row, 2);
        high(idx) = localNumber(row, 3);
        low(idx) = localNumber(row, 4);
        close(idx) = localNumber(row, 5);
        volume(idx) = localNumber(row, 6);
        closeTime(idx) = datetime(localNumber(row, 7) / 1000, "ConvertFrom", "posixtime", "TimeZone", displayTimeZone);
        quoteVolume(idx) = localNumber(row, 8);
        tradeCount(idx) = localNumber(row, 9);
    end

    candles = table(openTime, open, high, low, close, volume, closeTime, quoteVolume, tradeCount, ...
        'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume', 'CloseTime', 'QuoteVolume', 'TradeCount'});
end

function candles = localEmptyCandles()
    candles = table(NaT(0,1, "TimeZone", "Asia/Shanghai"), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), zeros(0,1), NaT(0,1, "TimeZone", "Asia/Shanghai"), zeros(0,1), zeros(0,1), ...
        'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume', 'CloseTime', 'QuoteVolume', 'TradeCount'});
end

function row = localRow(raw, idx)
    if iscell(raw)
        row = raw{idx};
    else
        row = raw(idx, :);
    end
end

function value = localNumber(row, idx)
    if iscell(row)
        item = row{idx};
    else
        item = row(idx);
    end

    if ischar(item) || isstring(item)
        value = str2double(item);
    else
        value = double(item);
    end
end
