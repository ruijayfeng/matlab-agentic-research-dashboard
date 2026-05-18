function [startIndex, windowSize] = zoomWindow(totalCandles, currentStart, currentWindow, scrollCount, centerFraction)
%ZOOMWINDOW Convert mouse-wheel movement into a candle-window zoom.
    if nargin < 5 || isnan(centerFraction)
        centerFraction = 0.5;
    end
    centerFraction = min(max(double(centerFraction), 0), 1);
    scrollCount = double(scrollCount);

    [currentStart, currentWindow] = crypto.chart.normalizeWindow(totalCandles, currentWindow, currentStart);
    centerIndex = currentStart + (currentWindow - 1) * centerFraction;

    zoomStep = 1.18;
    if scrollCount < 0
        nextWindow = floor(currentWindow / (zoomStep ^ abs(scrollCount)));
    elseif scrollCount > 0
        nextWindow = ceil(currentWindow * (zoomStep ^ scrollCount));
    else
        nextWindow = currentWindow;
    end

    nextWindow = min(max(20, nextWindow), min(500, max(1, totalCandles)));
    nextStart = round(centerIndex - (nextWindow - 1) * centerFraction);
    [startIndex, windowSize] = crypto.chart.normalizeWindow(totalCandles, nextWindow, nextStart);
end
