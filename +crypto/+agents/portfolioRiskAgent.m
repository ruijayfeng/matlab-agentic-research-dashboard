function result = portfolioRiskAgent(context)
%PORTFOLIORISKAGENT Summarize concentration and risk contribution.
    if ~isfield(context, "RiskContributions") || isempty(context.RiskContributions) || height(context.RiskContributions) == 0
        result = crypto.agents.makeResult("PortfolioRiskAgent", "Portfolio risk analysis", ...
            "skipped", 0.25, "缺少持仓风险贡献，无法评估组合风险", "没有风险贡献表", "缺失持仓风险证据", "先录入或导入持仓");
        return
    end

    risk = context.RiskContributions;
    topRisk = risk(1, :);
    allocationRank = sortrows(risk, "Allocation", "descend");
    topAllocation = allocationRank(1, :);
    cryptoRows = strcmp(string(risk.AssetClass), "Crypto");
    cryptoRisk = sum(risk.RiskContribution(cryptoRows), "omitnan");

    evidence = [
        "最大风险贡献: " + string(topRisk.Symbol) + " " + localPercent(topRisk.RiskContribution);
        "最大持仓权重: " + string(topAllocation.Symbol) + " " + localPercent(topAllocation.Allocation);
        "加密资产风险贡献: " + localPercent(cryptoRisk)
        ];

    risks = strings(0, 1);
    if topAllocation.Allocation >= 0.5
        risks(end + 1, 1) = "集中度较高: " + string(topAllocation.Symbol);
    end
    if cryptoRisk >= 0.65
        risks(end + 1, 1) = "组合风险主要由加密资产驱动";
    end

    if isempty(risks)
        status = "completed";
        headline = "组合风险分布可接受";
        recommendation = "维持当前风险预算，持续观察波动变化";
        confidence = 0.78;
    else
        status = "warning";
        headline = string(topRisk.Symbol) + " 风险贡献偏高，集中度需要关注";
        recommendation = "控制新增高相关资产，必要时降低集中持仓";
        confidence = 0.82;
    end

    result = crypto.agents.makeResult("PortfolioRiskAgent", "Portfolio risk analysis", ...
        status, confidence, headline, evidence, risks, recommendation);
end

function value = localPercent(number)
    if isnan(number)
        value = "无数据";
    else
        value = string(sprintf("%.1f%%", number * 100));
    end
end
