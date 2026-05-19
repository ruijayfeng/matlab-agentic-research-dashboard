function result = dataQualityAgent(context)
%DATAQUALITYAGENT Check whether the research context is complete enough.
    risks = strings(0, 1);
    evidence = strings(0, 1);

    if ~isfield(context, "MarketSnapshot") || isempty(context.MarketSnapshot) || height(context.MarketSnapshot) == 0
        risks(end + 1, 1) = "缺失市场快照";
    else
        evidence(end + 1, 1) = "市场快照覆盖 " + height(context.MarketSnapshot) + " 个资产";
    end

    if ~isfield(context, "TechnicalState") || isempty(context.TechnicalState) || height(context.TechnicalState) < 3
        risks(end + 1, 1) = "缺失足够技术状态";
    else
        evidence(end + 1, 1) = "技术状态覆盖 " + height(context.TechnicalState) + " 个资产";
    end

    if ~isfield(context, "Correlation") || ~isfield(context.Correlation, "Matrix") || isempty(context.Correlation.Matrix)
        risks(end + 1, 1) = "缺失跨资产相关性矩阵";
    else
        evidence(end + 1, 1) = "跨资产相关性可用";
    end

    if ~isfield(context, "RiskContributions") || isempty(context.RiskContributions) || height(context.RiskContributions) == 0
        risks(end + 1, 1) = "缺失持仓风险贡献";
    else
        evidence(end + 1, 1) = "持仓风险贡献可用";
    end

    if isempty(evidence)
        evidence = "没有可用证据";
    end

    if isempty(risks)
        status = "completed";
        confidence = 0.92;
        headline = "数据质量可用于 Agent 集群分析";
        recommendation = "继续运行技术、风险和联动 Agent";
    else
        status = "warning";
        confidence = 0.55;
        headline = "数据上下文不完整，结论需要降级";
        recommendation = "优先补齐缺失数据后再提升结论权重";
    end

    result = crypto.agents.makeResult("DataQualityAgent", "Data quality review", ...
        status, confidence, headline, evidence, risks, recommendation);
end
