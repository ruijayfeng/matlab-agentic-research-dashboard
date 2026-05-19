function lines = formatCards(run)
%FORMATCARDS Render Agent outputs as research desk role notes.
    arguments
        run struct
    end

    if ~isfield(run, "AgentResults") || isempty(run.AgentResults)
        lines = "Agent 集群输出：等待分析。";
        return
    end

    lines = strings(0, 1);
    results = run.AgentResults;
    for idx = 1:numel(results)
        result = results(idx);
        lines = [
            lines;
            "----------------------------------------";
            localPersona(result.Name);
            "我看到: " + localObservation(result);
            "我的建议: " + localAdvice(result);
            "需要盯住: " + localWatch(result);
            ""
            ]; %#ok<AGROW>
    end
end

function text = localPersona(name)
    switch string(name)
        case "DataQualityAgent"
            text = "数据质检员";
        case "TechnicalAgent"
            text = "技术面研究员";
        case "PortfolioRiskAgent"
            text = "组合风控员";
        case "MacroLinkageAgent"
            text = "跨资产联动研究员";
        case "CriticAgent"
            text = "反方审查员";
        otherwise
            text = string(name);
    end
end

function text = localObservation(result)
    text = string(result.Headline);
    evidence = string(result.Evidence);
    evidence = evidence(strlength(evidence) > 0);
    if ~isempty(evidence)
        text = text + "。依据: " + strjoin(cellstr(evidence(1:min(2, numel(evidence)))'), "；");
    end
end

function text = localAdvice(result)
    text = string(result.Recommendation);
    if strlength(text) == 0
        text = "暂不采取动作，等待更多确认。";
    end
    switch string(result.Name)
        case "TechnicalAgent"
            if contains(string(result.Headline), "偏强") || contains(string(result.Headline), "偏多")
                text = text + " 交易上更适合回撤低吸，不适合情绪化追高。";
            end
        case "PortfolioRiskAgent"
            if string(result.Status) == "warning"
                text = text + " 仓位上先处理集中风险，再谈进攻。";
            end
        case "CriticAgent"
            if string(result.Status) == "warning"
                text = "把前面偏乐观的结论降一级使用。" + text;
            end
    end
end

function text = localWatch(result)
    risks = string(result.Risks);
    risks = risks(strlength(risks) > 0);
    if isempty(risks)
        text = "暂无特别风险，继续观察信号是否延续。";
    else
        text = strjoin(cellstr(risks(:)'), "；");
    end
end
