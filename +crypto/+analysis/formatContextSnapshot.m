function lines = formatContextSnapshot(context)
%FORMATCONTEXTSNAPSHOT Summarize MATLAB-calculated evidence for the AI panel.
    arguments
        context struct
    end

    lines = [
        "MATLAB 计算快照";
        "分析资产池: " + strjoin(cellstr(string(context.Universe)), ", ")
        ];

    risk = context.RiskContributions;
    if ~isempty(risk) && height(risk) > 0
        topRisk = risk(1, :);
        cryptoRows = strcmp(string(risk.AssetClass), "Crypto");
        cryptoRisk = sum(risk.RiskContribution(cryptoRows), "omitnan");
        lines = [
            lines;
            "最大风险贡献: " + string(topRisk.Symbol) + " (" + localPercent(topRisk.RiskContribution) + ")";
            "最大持仓权重: " + localLargestAllocation(risk);
            "加密资产风险贡献: " + localPercent(cryptoRisk)
            ];
        lines = [lines; localRiskRows(risk)];
    end

    technical = context.TechnicalState;
    if ~isempty(technical) && height(technical) > 0
        ranked = sortrows(technical, "Return20D", "descend");
        strongest = "n/a";
        weakest = "n/a";
        if height(ranked) > 0 && ~isnan(ranked.Return20D(1))
            strongest = string(ranked.Symbol(1)) + " " + localPercent(ranked.Return20D(1));
        end
        if height(ranked) > 0 && ~isnan(ranked.Return20D(end))
            weakest = string(ranked.Symbol(end)) + " " + localPercent(ranked.Return20D(end));
        end
        lines = [
            lines;
            "20日最强资产: " + strongest;
            "20日最弱资产: " + weakest
            ];
    end

    if isfield(context, 'Correlation') && isfield(context.Correlation, 'AverageCorrelation')
        lines(end + 1, 1) = "平均相关性: " + string(sprintf("%.2f", context.Correlation.AverageCorrelation));
    end

    if isfield(context, 'StrategyScores') && ~isempty(context.StrategyScores) && height(context.StrategyScores) > 0
        lines = [lines; "多策略评分: " + localStrategySummary(context.StrategyScores)];
    end

    signals = string(context.Signals);
    if isempty(signals)
        signalText = "无";
    else
        signalText = strjoin(cellstr(signals), ", ");
    end
    lines(end + 1, 1) = "信号: " + signalText;
end

function text = localStrategySummary(scores)
    top = scores(1, :);
    bottom = scores(end, :);
    text = string(top.Symbol) + " " + top.CompositeView + " (" + string(top.CompositeScore) + ...
        ")，最低 " + string(bottom.Symbol) + " " + bottom.CompositeView + " (" + string(bottom.CompositeScore) + ")";
end

function lines = localRiskRows(risk)
    maxRows = min(4, height(risk));
    lines = strings(maxRows, 1);
    for idx = 1:maxRows
        lines(idx) = "持仓风险 #" + idx + ": " + string(risk.Symbol(idx)) + ...
            " 权重 " + localPercent(risk.Allocation(idx)) + ...
            ", 风险贡献 " + localPercent(risk.RiskContribution(idx));
    end
end

function text = localLargestAllocation(risk)
    ranked = sortrows(risk, "Allocation", "descend");
    text = string(ranked.Symbol(1)) + " (" + localPercent(ranked.Allocation(1)) + ")";
end

function value = localPercent(number)
    if isnan(number)
        value = "无数据";
    else
        value = string(sprintf("%.1f%%", number * 100));
    end
end
