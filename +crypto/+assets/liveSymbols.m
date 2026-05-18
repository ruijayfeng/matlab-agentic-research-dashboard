function symbols = liveSymbols()
%LIVESYMBOLS Symbols with implemented live data adapters.
    assets = crypto.assets.universe();
    symbols = assets.Symbol(assets.IsLive & strcmp(assets.DataSource, "Binance"));
end
