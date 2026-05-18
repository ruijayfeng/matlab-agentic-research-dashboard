function outputPath = writePositions(positions, outputPath)
%WRITEPOSITIONS Write normalized portfolio positions to CSV/XLSX.
    arguments
        positions table
        outputPath (1,1) string
    end

    required = ["Symbol", "AssetClass", "Quantity", "CostBasis"];
    missing = setdiff(required, string(positions.Properties.VariableNames));
    if ~isempty(missing)
        error("crypto:portfolio:MissingColumns", "Positions table is missing: %s", strjoin(missing, ", "));
    end
    outputPath = crypto.export.writeTable(positions(:, required), outputPath);
end
