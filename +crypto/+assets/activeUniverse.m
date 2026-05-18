function assets = activeUniverse()
%ACTIVEUNIVERSE Return rows enabled for latest-price and portfolio views.
    assets = crypto.assets.universe();
    hasAlphaVantage = strlength(crypto.config.getApiKey("ALPHAVANTAGE")) > 0;
    hasFmp = strlength(crypto.config.getApiKey("FMP")) > 0;
    rows = assets.IsLive | ...
        strcmp(assets.DataSource, "Stooq") | ...
        (hasFmp & strcmp(assets.DataSource, "FMP")) | ...
        (hasAlphaVantage & strcmp(assets.DataSource, "AlphaVantage"));
    assets = assets(rows, :);
end
