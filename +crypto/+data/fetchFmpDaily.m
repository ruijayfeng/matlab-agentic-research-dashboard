function candles = fetchFmpDaily(symbol, apiKey)
%FETCHFMPDAILY Fetch daily OHLCV data from Financial Modeling Prep.
    arguments
        symbol (1,1) string
        apiKey (1,1) string
    end

    if strlength(apiKey) == 0
        error("crypto:data:MissingApiKey", "Set FMP_API_KEY before fetching %s.", symbol);
    end

    raw = webread(char("https://financialmodelingprep.com/stable/historical-price-eod/full"), ...
        "symbol", char(symbol), ...
        "apikey", char(apiKey));

    if isfield(raw, "Error_Message")
        error("crypto:data:FmpError", "FMP did not return price data for %s: %s", symbol, string(raw.Error_Message));
    end
    historical = localHistoricalRows(raw);
    if isempty(historical)
        error("crypto:data:FmpFormat", "FMP response for %s has no historical price data.", symbol);
    end

    rows = numel(historical);
    openTime = NaT(rows, 1, "TimeZone", "Asia/Shanghai");
    closeTime = NaT(rows, 1, "TimeZone", "Asia/Shanghai");
    open = zeros(rows, 1);
    high = zeros(rows, 1);
    low = zeros(rows, 1);
    close = zeros(rows, 1);
    volume = zeros(rows, 1);

    for idx = 1:rows
        point = historical(idx);
        openTime(idx) = datetime(string(point.date), "InputFormat", "yyyy-MM-dd", "TimeZone", "Asia/Shanghai");
        closeTime(idx) = openTime(idx) + days(1) - seconds(1);
        open(idx) = localNumber(point, "open");
        high(idx) = localNumber(point, "high");
        low(idx) = localNumber(point, "low");
        close(idx) = localNumber(point, "close");
        volume(idx) = localNumber(point, "volume");
    end

    candles = table(openTime, open, high, low, close, volume, closeTime, volume .* close, zeros(rows, 1), ...
        'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume', 'CloseTime', 'QuoteVolume', 'TradeCount'});
    candles = sortrows(candles, "OpenTime");
end

function historical = localHistoricalRows(raw)
    if isstruct(raw) && isfield(raw, "historical")
        historical = raw.historical;
    elseif isstruct(raw) && numel(raw) > 1 && isfield(raw, "date")
        historical = raw;
    elseif iscell(raw)
        historical = [raw{:}];
    else
        historical = [];
    end
end

function value = localNumber(point, fieldName)
    fieldName = char(fieldName);
    if isfield(point, fieldName)
        value = double(point.(fieldName));
    else
        value = NaN;
    end
end
