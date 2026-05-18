function positions = readPositions(inputPath)
%READPOSITIONS Read portfolio positions from CSV/XLSX.
    arguments
        inputPath (1,1) string
    end

    raw = crypto.export.readTable(inputPath);
    names = string(raw.Properties.VariableNames);
    aliases = struct( ...
        "Symbol", ["Symbol", "Asset"], ...
        "AssetClass", ["AssetClass", "Class"], ...
        "Quantity", ["Quantity", "Qty"], ...
        "CostBasis", ["CostBasis", "Cost"]);
    positions = table( ...
        string(raw.(localColumn(names, aliases.Symbol))), ...
        string(raw.(localColumn(names, aliases.AssetClass))), ...
        double(raw.(localColumn(names, aliases.Quantity))), ...
        double(raw.(localColumn(names, aliases.CostBasis))), ...
        'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
    positions.Symbol = upper(strtrim(positions.Symbol));
    positions.AssetClass = strtrim(positions.AssetClass);
    positions.Quantity(isnan(positions.Quantity)) = 0;
    positions.CostBasis(isnan(positions.CostBasis)) = 0;
end

function name = localColumn(names, candidates)
    for idx = 1:numel(candidates)
        match = strcmpi(names, candidates(idx));
        if any(match)
            name = names(find(match, 1, "first"));
            return
        end
    end
    error("crypto:portfolio:MissingColumn", "Holdings file is missing one of: %s.", strjoin(candidates, ", "));
end
