function candles = fetchAlphaVantageDaily(symbol, apiKey, outputSize)
%FETCHALPHAVANTAGEDAILY Fetch daily OHLCV data from Alpha Vantage.
    arguments
        symbol (1,1) string
        apiKey (1,1) string
        outputSize (1,1) string = "compact"
    end

    if strlength(apiKey) == 0
        error("crypto:data:MissingApiKey", "Set ALPHAVANTAGE_API_KEY before fetching %s.", symbol);
    end

    raw = webread(char("https://www.alphavantage.co/query"), ...
        "function", "TIME_SERIES_DAILY", ...
        "symbol", char(symbol), ...
        "outputsize", char(outputSize), ...
        "apikey", char(apiKey));

    if isfield(raw, "Note") || isfield(raw, "Information")
        error("crypto:data:AlphaVantageLimit", "Alpha Vantage did not return price data for %s: %s", symbol, localMessage(raw));
    end

    seriesName = localSeriesField(raw);
    if strlength(seriesName) == 0
        error("crypto:data:AlphaVantageFormat", "Alpha Vantage response for %s has no time series field.", symbol);
    end

    series = raw.(char(seriesName));
    dateFields = fieldnames(series);
    rows = numel(dateFields);
    openTime = NaT(rows, 1, "TimeZone", "Asia/Shanghai");
    closeTime = NaT(rows, 1, "TimeZone", "Asia/Shanghai");
    open = zeros(rows, 1);
    high = zeros(rows, 1);
    low = zeros(rows, 1);
    close = zeros(rows, 1);
    volume = zeros(rows, 1);

    for idx = 1:rows
        dateText = dateFields{idx};
        dateText = strrep(dateText, "x", "");
        dateText = strrep(dateText, "_", "-");
        point = series.(dateFields{idx});
        openTime(idx) = datetime(dateText, "InputFormat", "yyyy-MM-dd", "TimeZone", "Asia/Shanghai");
        closeTime(idx) = openTime(idx) + days(1) - seconds(1);
        open(idx) = localFieldNumber(point, "open");
        high(idx) = localFieldNumber(point, "high");
        low(idx) = localFieldNumber(point, "low");
        close(idx) = localFieldNumber(point, "close");
        volume(idx) = localFieldNumber(point, "volume");
    end

    candles = table(openTime, open, high, low, close, volume, closeTime, volume .* close, zeros(rows, 1), ...
        'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume', 'CloseTime', 'QuoteVolume', 'TradeCount'});
    candles = sortrows(candles, "OpenTime");
end

function seriesName = localSeriesField(raw)
    seriesName = "";
    fields = fieldnames(raw);
    for idx = 1:numel(fields)
        field = fields{idx};
        lowerField = lower(string(field));
        if contains(lowerField, "note") || contains(lowerField, "information") || contains(lowerField, "meta")
            continue
        end
        value = raw.(field);
        if isstruct(value)
            valueFields = fieldnames(value);
            if numel(valueFields) >= 5
                seriesName = string(field);
                return
            end
        end
    end
end

function value = localFieldNumber(point, token)
    fields = fieldnames(point);
    match = fields(contains(lower(string(fields)), token));
    if isempty(match)
        value = NaN;
        return
    end
    value = str2double(string(point.(match{1})));
end

function message = localMessage(raw)
    if isfield(raw, "Note")
        message = string(raw.Note);
    elseif isfield(raw, "Information")
        message = string(raw.Information);
    else
        message = "unknown error";
    end
end
