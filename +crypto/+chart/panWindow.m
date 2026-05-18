function [startIndex, windowSize] = panWindow(totalCandles, currentStart, currentWindow, deltaCandles)
%PANWINDOW Move the visible candle window left or right by a candle delta.
    [currentStart, windowSize] = crypto.chart.normalizeWindow(totalCandles, currentWindow, currentStart);
    startIndex = currentStart + round(double(deltaCandles));
    [startIndex, windowSize] = crypto.chart.normalizeWindow(totalCandles, windowSize, startIndex);
end
