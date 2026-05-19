function result = macroLinkageAgent(context)
%MACROLINKAGEAGENT Summarize cross-asset linkage and hedge behavior.
    evidence = strings(0, 1);
    risks = strings(0, 1);
    confidence = 0.62;

    if isfield(context, "Correlation") && isfield(context.Correlation, "AverageCorrelation") && ~isnan(context.Correlation.AverageCorrelation)
        avgCorr = context.Correlation.AverageCorrelation;
        evidence(end + 1, 1) = "平均跨资产相关性: " + string(sprintf("%.2f", avgCorr));
        if avgCorr >= 0.65
            risks(end + 1, 1) = "相关性偏高，分散化保护可能下降";
            headline = "风险资产联动升温";
            recommendation = "压力场景下不要高估分散化效果";
            confidence = 0.72;
        else
            headline = "跨资产联动处于可控区间";
            recommendation = "继续观察风险资产与黄金的分化";
        end
    else
        headline = "缺少相关性证据，联动判断降级";
        recommendation = "补齐跨资产日线数据";
        risks(end + 1, 1) = "缺失相关性数据";
        confidence = 0.35;
    end

    if isfield(context, "TechnicalState") && ~isempty(context.TechnicalState) && height(context.TechnicalState) > 0
        technical = context.TechnicalState;
        goldRows = strcmp(string(technical.Symbol), "GLD");
        riskRows = strcmp(string(technical.AssetClass), "Crypto") | strcmp(string(technical.AssetClass), "US Equity");
        if any(goldRows) && any(riskRows)
            goldReturn = mean(technical.Return20D(goldRows), "omitnan");
            riskReturn = mean(technical.Return20D(riskRows), "omitnan");
            evidence(end + 1, 1) = "GLD 20日收益: " + localPercent(goldReturn) + ...
                ", 风险资产平均20日收益: " + localPercent(riskReturn);
        end
    end

    if isempty(evidence)
        evidence = "没有联动证据";
    end

    status = "completed";
    if ~isempty(risks)
        status = "warning";
    end

    result = crypto.agents.makeResult("MacroLinkageAgent", "Cross-asset linkage analysis", ...
        status, confidence, headline, evidence, risks, recommendation);
end

function value = localPercent(number)
    if isnan(number)
        value = "无数据";
    else
        value = string(sprintf("%.1f%%", number * 100));
    end
end
