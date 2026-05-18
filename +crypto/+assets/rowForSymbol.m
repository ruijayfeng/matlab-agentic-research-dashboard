function row = rowForSymbol(symbol)
%ROWFORSYMBOL Return active universe metadata for one symbol.
    assets = crypto.assets.activeUniverse();
    idx = find(strcmp(assets.Symbol, string(symbol)), 1, "first");
    if isempty(idx)
        error("crypto:assets:UnknownSymbol", "No active asset metadata for %s.", symbol);
    end
    row = assets(idx, :);
end
