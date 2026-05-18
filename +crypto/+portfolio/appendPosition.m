function positions = appendPosition(positions, symbol, assetClass)
%APPENDPOSITION Append a new normalized holding row.
    arguments
        positions table
        symbol (1,1) string
        assetClass (1,1) string = "Unknown"
    end

    symbol = upper(strtrim(symbol));
    if isempty(positions) || ~istable(positions)
        positions = table(strings(0, 1), strings(0, 1), zeros(0, 1), zeros(0, 1), ...
            'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
    end
    if any(strcmp(string(positions.Symbol), symbol))
        return
    end
    positions = [positions; table(symbol, assetClass, 0, 0, 'VariableNames', positions.Properties.VariableNames)]; %#ok<AGROW>
end

