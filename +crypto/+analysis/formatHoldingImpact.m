function lines = formatHoldingImpact(context)
%FORMATHOLDINGIMPACT Format holding-driven evidence for the AI workbench.
    arguments
        context struct
    end

    lines = "持仓影响";
    if ~isfield(context, 'RiskContributions') || isempty(context.RiskContributions) || height(context.RiskContributions) == 0
        lines(end + 1, 1) = "暂无持仓风险贡献。";
        return
    end
    risk = context.RiskContributions;
    top = risk(1, :);
    cryptoRows = strcmp(string(risk.AssetClass), "Crypto");
    cryptoRisk = sum(risk.RiskContribution(cryptoRows), "omitnan");
    lines = [
        lines;
        "最大风险贡献: " + string(top.Symbol) + "，风险贡献 " + localPercent(top.RiskContribution);
        "加密资产风险贡献: " + localPercent(cryptoRisk);
        "持仓结论: 风险贡献越高，AI 对该资产趋势和波动信号的权重越高。"
        ];
end

function value = localPercent(number)
    if isnan(number)
        value = "无数据";
    else
        value = string(sprintf("%.1f%%", number * 100));
    end
end
