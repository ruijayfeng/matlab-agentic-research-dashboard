function result = makeResult(name, role, status, confidence, headline, evidence, risks, recommendation)
%MAKERESULT Create a normalized Agent result struct.
    arguments
        name string
        role string
        status string
        confidence double
        headline string
        evidence string = strings(0, 1)
        risks string = strings(0, 1)
        recommendation string = ""
    end

    result = struct();
    result.Name = name;
    result.Role = role;
    result.Status = localStatus(status);
    result.Confidence = min(max(confidence, 0), 1);
    result.Headline = headline;
    result.Evidence = evidence(:);
    result.Risks = risks(:);
    result.Recommendation = recommendation;
    result.Timestamp = datetime("now", "TimeZone", "Asia/Shanghai");
end

function status = localStatus(status)
    allowed = ["completed", "warning", "failed", "skipped"];
    status = lower(string(status));
    if ~any(status == allowed)
        status = "warning";
    end
end
