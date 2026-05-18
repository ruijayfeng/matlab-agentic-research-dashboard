function result = analyzeContext(context)
%ANALYZECONTEXT Produce local rule-based AI analysis from structured context.
    arguments
        context struct
    end

    highlights = strings(0, 1);
    lines = [
        "AI 分析";
        "分析来源: 本地规则";
        "关注重点: 持仓风险、跨资产相关性、波动状态"
        ];

    risk = context.RiskContributions;
    technical = context.TechnicalState;
    signals = string(context.Signals);

    if ~isempty(risk) && height(risk) > 0
        topRisk = risk(1, :);
        highlights(end + 1, 1) = "最大风险贡献: " + string(topRisk.Symbol) + ...
            "，风险贡献 " + localPercent(topRisk.RiskContribution);
        lines(end + 1, 1) = "风险: " + highlights(end);

        topAllocation = sortrows(risk, "Allocation", "descend");
        if topAllocation.Allocation(1) >= 0.5 || any(signals == "ConcentrationRisk")
            concentration = "集中度风险: " + string(topAllocation.Symbol(1)) + ...
                " 占已投资资产 " + localPercent(topAllocation.Allocation(1));
            highlights(end + 1, 1) = concentration;
            lines(end + 1, 1) = concentration + "。";
        end

        cryptoRows = strcmp(risk.AssetClass, "Crypto");
        cryptoRisk = sum(risk.RiskContribution(cryptoRows), "omitnan");
        if cryptoRisk >= 0.65 || any(signals == "CryptoRiskDominant")
            text = "加密资产风险占主导，风险贡献 " + localPercent(cryptoRisk);
            highlights(end + 1, 1) = text;
            lines(end + 1, 1) = text + "；组合波动更可能由 BTC/ETH/SOL 驱动，而不是 ETF 敞口。";
        end
    end

    if ~isempty(technical) && height(technical) > 0
        ranked = sortrows(technical, "Return20D", "descend");
        if height(ranked) >= 1 && ~isnan(ranked.Return20D(1))
            text = "20日相对强势资产: " + string(ranked.Symbol(1)) + ...
                "，收益 " + localPercent(ranked.Return20D(1));
            highlights(end + 1, 1) = text;
            lines(end + 1, 1) = text + "。";
        end
        if height(ranked) >= 2 && ~isnan(ranked.Return20D(end))
            lines(end + 1, 1) = "20日相对弱势资产: " + string(ranked.Symbol(end)) + ...
                "，收益 " + localPercent(ranked.Return20D(end)) + "。";
        end

        volRows = technical.VolatilityPercentile >= 0.8 | technical.HasRecentAnomaly;
        if any(volRows) || any(signals == "VolatilityWatch")
            watchSymbols = strjoin(cellstr(string(technical.Symbol(volRows))), ", ");
            if strlength(watchSymbols) == 0
                watchSymbols = "多资产组合";
            end
            text = "波动观察: " + string(watchSymbols);
            highlights(end + 1, 1) = text;
            lines(end + 1, 1) = text + " 出现较高波动分位或近期异常收益。";
        end

        goldRow = strcmp(technical.Symbol, "GLD");
        riskRows = strcmp(technical.AssetClass, "Crypto") | strcmp(technical.AssetClass, "US Equity");
        if any(goldRow) && any(riskRows)
            goldReturn = technical.Return20D(goldRow);
            riskReturn = mean(technical.Return20D(riskRows), "omitnan");
            if goldReturn > 0 && riskReturn < 0
                text = "黄金对冲特征正在增强";
                highlights(end + 1, 1) = text;
                lines(end + 1, 1) = text + "：20日窗口内 GLD 为正，而风险资产为负。";
            end
        end
    end

    if isfield(context, 'Correlation') && isfield(context.Correlation, 'AverageCorrelation')
        avgCorr = context.Correlation.AverageCorrelation;
        if ~isnan(avgCorr)
            if avgCorr >= 0.65
                corrText = "跨资产相关性偏高，平均相关性 " + sprintf("%.2f", avgCorr);
                highlights(end + 1, 1) = corrText;
                lines(end + 1, 1) = corrText + "；分散化效果可能下降。";
            else
                lines(end + 1, 1) = "跨资产相关性适中，平均相关性 " + sprintf("%.2f", avgCorr) + "。";
            end
        end
    end

    if isfield(context, 'StrategyScores') && ~isempty(context.StrategyScores) && height(context.StrategyScores) > 0
        topScore = context.StrategyScores(1, :);
        bottomScore = context.StrategyScores(end, :);
        lines(end + 1, 1) = "多策略综合: " + string(topScore.Symbol) + " 得分最高，为 " + ...
            string(topScore.CompositeScore) + "（" + topScore.CompositeView + "）；" + ...
            string(bottomScore.Symbol) + " 得分最低，为 " + string(bottomScore.CompositeScore) + ...
            "（" + bottomScore.CompositeView + "）。";
    end

    if numel(lines) == 3
        lines(end + 1, 1) = "本地规则暂未触发主要风险提示。";
    end

    result = struct();
    result.Provider = "local-rules";
    result.GeneratedAt = datetime("now", "TimeZone", "Asia/Shanghai");
    result.Highlights = highlights;
    result.Text = strjoin(lines, newline);
    result.LLMAdapter = struct("Status", "reserved", "ExpectedInput", "context.LLMPayload");
end

function value = localPercent(number)
    if isnan(number)
        value = "无数据";
    else
        value = string(sprintf("%.1f%%", number * 100));
    end
end
