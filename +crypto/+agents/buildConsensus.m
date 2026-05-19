function [consensus, disagreements, watchlist, evidenceLog] = buildConsensus(agentResults)
%BUILDCONSENSUS Aggregate Agent outputs for dashboard rendering.
    agentNames = string({agentResults.Name})';
    headlines = string({agentResults.Headline})';
    recommendations = string({agentResults.Recommendation})';
    statuses = string({agentResults.Status})';

    warningRows = statuses == "warning";
    avgConfidence = mean([agentResults.Confidence], "omitnan");

    consensus = [
        "Agent 平均置信度: " + string(sprintf("%.0f%%", avgConfidence * 100));
        "主结论: " + localPrimaryConclusion(agentResults);
        "执行口径: " + localActionTone(agentResults)
        ];

    disagreements = strings(0, 1);
    if any(warningRows)
        warningNames = strjoin(cellstr(agentNames(warningRows)), ", ");
        disagreements(end + 1, 1) = "需要降级或复核的 Agent: " + string(warningNames);
    end
    criticRows = agentNames == "CriticAgent";
    if any(criticRows)
        critic = agentResults(find(criticRows, 1, "first"));
        if ~isempty(critic.Risks)
            disagreements = [disagreements; critic.Risks(:)];
        end
    end
    if isempty(disagreements)
        disagreements = "未发现主要分歧";
    end

    watchlist = strings(0, 1);
    for idx = 1:numel(agentResults)
        if strlength(agentResults(idx).Recommendation) > 0
            watchlist(end + 1, 1) = agentResults(idx).Name + ": " + agentResults(idx).Recommendation; %#ok<AGROW>
        end
    end

    evidenceLog = strings(0, 1);
    for idx = 1:numel(agentResults)
        lines = agentResults(idx).Evidence(:);
        for lineIdx = 1:numel(lines)
            evidenceLog(end + 1, 1) = agentResults(idx).Name + " | " + lines(lineIdx); %#ok<AGROW>
        end
    end

    if isempty(watchlist)
        watchlist = "等待更多 Agent 建议";
    end
    if isempty(evidenceLog)
        evidenceLog = "没有证据日志";
    end
end

function text = localPrimaryConclusion(agentResults)
    risk = localFind(agentResults, "PortfolioRiskAgent");
    technical = localFind(agentResults, "TechnicalAgent");
    if ~isempty(risk) && risk.Status == "warning"
        text = risk.Headline;
    elseif ~isempty(technical)
        text = technical.Headline;
    else
        text = "等待 Agent 结论";
    end
end

function text = localActionTone(agentResults)
    critic = localFind(agentResults, "CriticAgent");
    if ~isempty(critic) && critic.Status == "warning"
        text = "保守采用，先跟踪分歧与触发条件";
    else
        text = "可采用共识结论，并保留风险观察";
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
