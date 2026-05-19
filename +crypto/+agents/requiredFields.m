function fields = requiredFields()
%REQUIREDFIELDS Required fields for every research Agent result.
    fields = ["Name", "Role", "Status", "Confidence", "Headline", ...
        "Evidence", "Risks", "Recommendation", "Timestamp"];
end
