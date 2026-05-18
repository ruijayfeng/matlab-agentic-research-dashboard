function values = movingAverage(series, period)
%MOVINGAVERAGE Trailing simple moving average with leading NaN values.
    arguments
        series (:,1) double
        period (1,1) double {mustBeInteger, mustBePositive}
    end

    values = NaN(size(series));
    if numel(series) < period
        return
    end

    for idx = period:numel(series)
        window = series(idx - period + 1:idx);
        values(idx) = mean(window, "omitnan");
    end
end
