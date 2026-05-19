function lines = formatIntegratedRecommendation(run)
%FORMATINTEGRATEDRECOMMENDATION Render the Agent cluster decision for users.
    arguments
        run struct
    end

    if ~isfield(run, "AgentResults") || isempty(run.AgentResults)
        lines = [
            "综合建议";
            "等待 Agent 集群完成分析。"
            ];
        return
    end

    technical = localFind(run.AgentResults, "TechnicalAgent");
    risk = localFind(run.AgentResults, "PortfolioRiskAgent");
    macro = localFind(run.AgentResults, "MacroLinkageAgent");
    critic = localFind(run.AgentResults, "CriticAgent");

    marketView = localMarketView(technical, macro);
    positionView = localPositionView(technical, risk, critic);
    addView = localAddView(technical, risk, critic);
    reduceView = localReduceView(risk, critic);
    watchView = localWatchView(run, technical, risk, macro);

    lines = [
        "综合建议";
        "市场判断: " + marketView;
        "仓位建议: " + positionView;
        "可以加仓: " + addView;
        "需要减仓: " + reduceView;
        "重点观察: " + watchView;
        "执行提醒: 这不是自动交易信号，先按观察条件确认，再分批调整仓位。"
        ];
end

function text = localMarketView(technical, macro)
    text = "市场方向暂不明确，先等待更多数据。";
    if ~isempty(technical)
        headline = string(technical.Headline);
        if contains(headline, "偏强") || contains(headline, "偏多")
            text = "短期趋势仍偏建设性，但不适合无条件追涨。";
        elseif contains(headline, "偏弱")
            text = "短期趋势偏弱，应该优先控制回撤。";
        else
            text = "市场处在分化阶段，强弱切换比单边趋势更重要。";
        end
    end
    if ~isempty(macro) && (string(macro.Status) == "warning" || any(contains(string(macro.Risks), "相关性")))
        text = text + " 跨资产相关性升高时，BTC、ETH、SOL 和美股可能一起回撤。";
    end
end

function text = localPositionView(technical, risk, critic)
    text = "维持当前核心仓位，暂不做激进调整。";
    if ~isempty(risk) && string(risk.Status) == "warning"
        text = "组合先以风险控制为主，核心仓位可以保留，但新增仓位要放慢。";
    elseif ~isempty(technical) && (contains(string(technical.Headline), "偏强") || contains(string(technical.Headline), "偏多"))
        text = "已有仓位可以继续持有，回撤确认后再考虑小幅加仓。";
    end
    if ~isempty(critic) && string(critic.Status) == "warning"
        text = text + " 反方审查提示结论需要降级，因此不要一次性重仓操作。";
    end
end

function text = localAddView(technical, risk, critic)
    text = "暂不建议主动加仓，等待趋势和风险信号更一致。";
    if ~isempty(technical) && (contains(string(technical.Headline), "偏强") || contains(string(technical.Headline), "偏多"))
        text = "只考虑在回撤后分批加仓强势资产，优先观察 BTC/ETH，而不是追高波动最大的资产。";
    end
    if ~isempty(risk) && string(risk.Status) == "warning"
        text = "如果当前加密资产风险贡献已经偏高，加仓前先降低单一资产集中度。";
    end
    if ~isempty(critic) && string(critic.Status) == "warning"
        text = text + " 需要等反方审查里的冲突缓和后再执行。";
    end
end

function text = localReduceView(risk, critic)
    text = "暂不要求系统性减仓。";
    if ~isempty(risk) && string(risk.Status) == "warning"
        text = "优先减小风险贡献最高或仓位最集中的资产，避免组合被单一币种主导。";
    end
    if ~isempty(critic) && any(contains(string(critic.Risks), "冲突"))
        text = text + " 技术偏多和组合风险偏高发生冲突时，先减风险，不要先加风险。";
    end
end

function text = localWatchView(run, technical, risk, macro)
    items = strings(0, 1);
    if ~isempty(technical)
        items(end + 1, 1) = "BTC/ETH 是否继续站稳短期均线";
    end
    if ~isempty(risk)
        items(end + 1, 1) = "最大风险贡献资产是否继续扩大";
    end
    if ~isempty(macro)
        items(end + 1, 1) = "SPY/QQQ 与加密资产是否共振下跌，GLD 是否提供避险";
    end
    if isfield(run, "Disagreements") && ~isempty(run.Disagreements)
        items(end + 1, 1) = "Agent 分歧是否收敛";
    end
    if isempty(items)
        text = "等待行情、持仓和跨资产数据补齐。";
    else
        text = strjoin(cellstr(items(:)'), "；");
    end
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
