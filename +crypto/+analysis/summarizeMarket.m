function summary = summarizeMarket(tickers, candles, selectedSymbol)
%SUMMARIZEMARKET Produce deterministic AI-style insight text from metrics.
    arguments
        tickers table
        candles table
        selectedSymbol (1,1) string
    end

    idx = find(strcmp(string(tickers.Symbol), selectedSymbol), 1, "first");
    if isempty(idx)
        error("crypto:analysis:MissingSymbol", "Ticker table does not contain %s.", selectedSymbol);
    end

    lastClose = candles.Close(end);
    ma20 = candles.MA20(end);
    rsi14 = candles.RSI14(end);
    macdHist = candles.MACDHistogram(end);
    changePct = tickers.PriceChangePercent(idx);

    if lastClose >= ma20 && changePct >= 0 && macdHist >= 0
        trend = "bullish";
        trendText = "短期趋势偏建设性";
    elseif lastClose < ma20 && changePct < 0 && macdHist < 0
        trend = "bearish";
        trendText = "短期趋势偏弱";
    else
        trend = "neutral";
        trendText = "趋势信号分化";
    end

    if rsi14 >= 70
        momentumText = "RSI 处于过热区域，追涨风险较高";
    elseif rsi14 <= 30
        momentumText = "RSI 处于超卖区域，需要关注反弹条件";
    else
        momentumText = "RSI 处于中性区域";
    end

    anomalyRows = candles.IsReturnAnomaly;
    if any(anomalyRows)
        latestAnomaly = find(anomalyRows, 1, "last");
        anomalyText = sprintf("最近一次异常收益出现在 %s，收益 z-score 为 %.2f", ...
            string(candles.OpenTime(latestAnomaly)), candles.ReturnZScore(latestAnomaly));
    else
        anomalyText = "当前窗口未检测到显著异常收益";
    end

    leaderText = localRelativeStrength(tickers);
    text = sprintf("%s：%s。24小时变化 %.2f%%，最新价格 %.4f。%s，MACD 柱状图 %.4f。%s。%s。", ...
        selectedSymbol, trendText, changePct, tickers.LastPrice(idx), ...
        momentumText, macdHist, anomalyText, leaderText);

    summary = struct( ...
        "Symbol", selectedSymbol, ...
        "Trend", trend, ...
        "RSI14", rsi14, ...
        "MACDHistogram", macdHist, ...
        "Text", text);
end

function text = localRelativeStrength(tickers)
    [maxChange, maxIdx] = max(tickers.PriceChangePercent);
    [minChange, minIdx] = min(tickers.PriceChangePercent);
    text = sprintf("相对强弱：%s 最强（%.2f%%），%s 最弱（%.2f%%）", ...
        string(tickers.Symbol(maxIdx)), maxChange, string(tickers.Symbol(minIdx)), minChange);
end
