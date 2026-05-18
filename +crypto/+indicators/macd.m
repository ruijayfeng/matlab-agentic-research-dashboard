function [macdLine, signalLine, histogram] = macd(series, fastPeriod, slowPeriod, signalPeriod)
%MACD Moving average convergence divergence using exponential averages.
    arguments
        series (:,1) double
        fastPeriod (1,1) double {mustBeInteger, mustBePositive} = 12
        slowPeriod (1,1) double {mustBeInteger, mustBePositive} = 26
        signalPeriod (1,1) double {mustBeInteger, mustBePositive} = 9
    end

    fast = localEma(series, fastPeriod);
    slow = localEma(series, slowPeriod);
    macdLine = fast - slow;
    signalLine = localEma(macdLine, signalPeriod);
    histogram = macdLine - signalLine;
end

function values = localEma(series, period)
    values = NaN(size(series));
    if isempty(series)
        return
    end

    alpha = 2 / (period + 1);
    firstValid = find(~isnan(series), 1, "first");
    if isempty(firstValid)
        return
    end

    values(firstValid) = series(firstValid);
    for idx = firstValid + 1:numel(series)
        if isnan(series(idx))
            values(idx) = values(idx - 1);
        else
            values(idx) = alpha * series(idx) + (1 - alpha) * values(idx - 1);
        end
    end
end
