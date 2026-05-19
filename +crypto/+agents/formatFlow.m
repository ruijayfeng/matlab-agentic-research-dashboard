function lines = formatFlow(run)
%FORMATFLOW Format Agent statuses as a compact visible flow strip.
    arguments
        run struct
    end

    if ~isfield(run, "AgentResults") || isempty(run.AgentResults)
        lines = "Agent flow: waiting for research run";
        return
    end

    results = run.AgentResults;
    parts = strings(1, numel(results));
    for idx = 1:numel(results)
        parts(idx) = string(results(idx).Name) + " [" + string(results(idx).Status) + ...
            ", " + string(sprintf("%.0f%%", results(idx).Confidence * 100)) + "]";
    end
    lines = [
        "Agent Flow";
        strjoin(cellstr(parts), " -> ")
        ];
end
