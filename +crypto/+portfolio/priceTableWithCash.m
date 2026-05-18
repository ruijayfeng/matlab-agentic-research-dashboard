function prices = priceTableWithCash(tickers)
%PRICETABLEWITHCASH Convert market tickers into portfolio price rows.
    prices = tickers(:, {'Symbol', 'LastPrice'});
    if ~any(strcmp(string(prices.Symbol), "USDT"))
        prices = [prices; table("USDT", 1, 'VariableNames', {'Symbol', 'LastPrice'})];
    end
end
