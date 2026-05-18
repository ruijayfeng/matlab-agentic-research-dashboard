function [startIndex, windowSize, maxStart] = normalizeWindow(totalCandles, windowSize, startIndex)
%NORMALIZEWINDOW Clamp candle window state to a valid range.
    totalCandles = max(0, floor(double(totalCandles)));
    windowSize = max(1, floor(double(windowSize)));
    startIndex = max(1, round(double(startIndex)));

    if totalCandles == 0
        windowSize = 1;
        maxStart = 1;
        startIndex = 1;
        return
    end

    windowSize = min(windowSize, totalCandles);
    maxStart = max(1, totalCandles - windowSize + 1);
    startIndex = min(max(1, startIndex), maxStart);
end
