function result = criticAgent(context, previousResults)
%CRITICAGENT Challenge overconfident or conflicting Agent conclusions.
    arguments
        context struct
        previousResults struct
    end

    evidence = strings(0, 1);
    risks = strings(0, 1);
    lowConfidence = [previousResults.Confidence] < 0.6;
    warningStatus = string({previousResults.Status}) == "warning";

    if any(lowConfidence)
        risks(end + 1, 1) = "多个 Agent 置信度不足，汇总结论需要降级";
    end
    if any(warningStatus)
        evidence(end + 1, 1) = "检测到 " + sum(warningStatus) + " 个 Agent 给出 warning";
    end

    technical = localFind(previousResults, "TechnicalAgent");
    risk = localFind(previousResults, "PortfolioRiskAgent");
    dataQuality = localFind(previousResults, "DataQualityAgent");

    if ~isempty(dataQuality) && dataQuality.Status == "warning"
        risks(end + 1, 1) = "数据质量 warning 会影响后续 Agent 结论";
    end

    if ~isempty(technical) && ~isempty(risk)
        techBullish = contains(technical.Headline, "偏强") || contains(technical.Headline, "偏多");
        riskConcentrated = contains(risk.Headline, "集中") || any(contains(risk.Risks, "集中"));
        if techBullish && riskConcentrated
            risks(end + 1, 1) = "冲突: 技术 Agent 偏多，但风险 Agent 提示集中度较高";
        end
    end

    if isempty(evidence)
        evidence = "已检查前序 Agent 输出";
    end

    if isempty(risks)
        status = "completed";
        confidence = 0.76;
        headline = "未发现主要结论冲突";
        recommendation = "可以采用共识结论，但仍需保留观察条件";
    else
        status = "warning";
        confidence = 0.69;
        headline = "结论需降级，存在证据或风险冲突";
        recommendation = "采用更保守的行动建议，并优先跟踪触发条件";
    end

    result = crypto.agents.makeResult("CriticAgent", "Adversarial research review", ...
        status, confidence, headline, evidence, risks, recommendation);
end

function result = localFind(results, name)
    result = [];
    for idx = 1:numel(results)
        if string(results(idx).Name) == string(name)
            result = results(idx);
            return
        end
    end
end
