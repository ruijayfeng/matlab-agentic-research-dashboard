function lines = formatMarketLinkage(context)
%FORMATMARKETLINKAGE Format cross-asset linkage evidence.
    arguments
        context struct
    end

    lines = "市场联动";
    if isfield(context, 'Correlation') && isfield(context.Correlation, 'AverageCorrelation') && ~isnan(context.Correlation.AverageCorrelation)
        avgCorr = context.Correlation.AverageCorrelation;
        lines(end + 1, 1) = "平均相关性: " + string(sprintf("%.2f", avgCorr));
        if avgCorr >= 0.65
            lines(end + 1, 1) = "联动判断: 相关性偏高，分散化效果可能下降。";
        else
            lines(end + 1, 1) = "联动判断: 相关性未处于高压状态。";
        end
    else
        lines(end + 1, 1) = "平均相关性: 无数据";
    end
    if isfield(context, 'StrategyScores') && ~isempty(context.StrategyScores) && height(context.StrategyScores) > 0
        scores = context.StrategyScores;
        lines(end + 1, 1) = "策略最高分: " + string(scores.Symbol(1)) + " " + string(scores.CompositeScore(1)) + "（" + scores.CompositeView(1) + "）";
        lines(end + 1, 1) = "策略最低分: " + string(scores.Symbol(end)) + " " + string(scores.CompositeScore(end)) + "（" + scores.CompositeView(end) + "）";
    end
end
