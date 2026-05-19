function result = technicalAgent(context)
%TECHNICALAGENT Summarize trend and momentum from technical state.
    if ~isfield(context, "TechnicalState") || isempty(context.TechnicalState) || height(context.TechnicalState) == 0
        result = crypto.agents.makeResult("TechnicalAgent", "Technical market analysis", ...
            "skipped", 0.2, "缺少技术状态，无法判断趋势", "没有技术状态表", "缺失技术证据", "等待数据补齐");
        return
    end

    technical = context.TechnicalState;
    ranked = sortrows(technical, "Return20D", "descend");
    strongest = ranked(1, :);
    weakest = ranked(end, :);
    avgReturn = mean(technical.Return20D, "omitnan");
    hotRows = technical.VolatilityPercentile >= 0.8 | technical.HasRecentAnomaly;

    evidence = [
        "20日最强资产: " + string(strongest.Symbol) + " " + localPercent(strongest.Return20D);
        "20日最弱资产: " + string(weakest.Symbol) + " " + localPercent(weakest.Return20D);
        "资产池平均20日收益: " + localPercent(avgReturn)
        ];
    risks = strings(0, 1);
    if any(hotRows)
        risks(end + 1, 1) = "部分资产处于高波动或异常收益观察区";
    end

    if avgReturn > 0.03
        headline = "趋势偏强，风险资产动量占优";
        recommendation = "持有为主，新增仓位等待回撤确认";
        confidence = 0.74;
    elseif avgReturn < -0.03
        headline = "趋势偏弱，优先控制回撤";
        recommendation = "降低进攻性仓位，等待企稳信号";
        confidence = 0.72;
    else
        headline = "趋势分化，等待更明确方向";
        recommendation = "维持观察，关注强弱切换";
        confidence = 0.64;
    end

    result = crypto.agents.makeResult("TechnicalAgent", "Technical market analysis", ...
        "completed", confidence, headline, evidence, risks, recommendation);
end

function value = localPercent(number)
    if isnan(number)
        value = "无数据";
    else
        value = string(sprintf("%.1f%%", number * 100));
    end
end
