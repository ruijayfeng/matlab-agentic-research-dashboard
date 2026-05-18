function values = rsi(closePrices, period)
%RSI Relative strength index with Wilder-style smoothing.
    arguments
        closePrices (:,1) double
        period (1,1) double {mustBeInteger, mustBePositive} = 14
    end

    values = NaN(size(closePrices));
    if numel(closePrices) <= period
        return
    end

    changes = diff(closePrices);
    gains = max(changes, 0);
    losses = max(-changes, 0);

    avgGain = mean(gains(1:period), "omitnan");
    avgLoss = mean(losses(1:period), "omitnan");
    values(period + 1) = localRsi(avgGain, avgLoss);

    for idx = period + 2:numel(closePrices)
        gain = gains(idx - 1);
        loss = losses(idx - 1);
        avgGain = ((period - 1) * avgGain + gain) / period;
        avgLoss = ((period - 1) * avgLoss + loss) / period;
        values(idx) = localRsi(avgGain, avgLoss);
    end
end

function value = localRsi(avgGain, avgLoss)
    if avgLoss == 0
        value = 100;
        return
    end

    rs = avgGain / avgLoss;
    value = 100 - (100 / (1 + rs));
end
