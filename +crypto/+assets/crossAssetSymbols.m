function symbols = crossAssetSymbols()
%CROSSASSETSYMBOLS Symbols for the cross-asset daily chart panel.
    assets = crypto.assets.activeUniverse();
    rows = strcmp(assets.DataSource, "Stooq") | strcmp(assets.DataSource, "FMP") | strcmp(assets.DataSource, "AlphaVantage");
    symbols = assets.Symbol(rows);
end
