function run = runResearchAgents(context)
%RUNRESEARCHAGENTS Run the MATLAB-native research Agent cluster.
    arguments
        context struct
    end

    startedAt = datetime("now", "TimeZone", "Asia/Shanghai");
    dataQuality = crypto.agents.dataQualityAgent(context);
    technical = crypto.agents.technicalAgent(context);
    portfolioRisk = crypto.agents.portfolioRiskAgent(context);
    macroLinkage = crypto.agents.macroLinkageAgent(context);
    previous = [dataQuality, technical, portfolioRisk, macroLinkage];
    critic = crypto.agents.criticAgent(context, previous);
    agentResults = [previous, critic];
    [consensus, disagreements, watchlist, evidenceLog] = crypto.agents.buildConsensus(agentResults);

    run = struct();
    run.RunId = "agent-run-" + string(datetime(startedAt, "Format", "yyyyMMdd-HHmmss"));
    if isfield(context, "Version")
        run.ContextVersion = string(context.Version);
    else
        run.ContextVersion = "unknown";
    end
    run.StartedAt = startedAt;
    run.CompletedAt = datetime("now", "TimeZone", "Asia/Shanghai");
    run.AgentResults = agentResults;
    run.Consensus = consensus(:);
    run.Disagreements = disagreements(:);
    run.ActionWatchlist = watchlist(:);
    run.EvidenceLog = evidenceLog(:);
    run.IntegratedRecommendation = crypto.agents.formatIntegratedRecommendation(run);
end
