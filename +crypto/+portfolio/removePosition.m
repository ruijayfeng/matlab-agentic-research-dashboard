function positions = removePosition(positions, symbol)
%REMOVEPOSITION Remove a holding row by symbol.
    arguments
        positions table
        symbol (1,1) string
    end

    if isempty(positions) || height(positions) == 0
        return
    end
    mask = ~strcmp(string(positions.Symbol), upper(strtrim(symbol)));
    positions = positions(mask, :);
end
