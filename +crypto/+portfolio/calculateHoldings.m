function result = calculateHoldings(holdings, prices)
%CALCULATEHOLDINGS Compute current value, PnL, and allocation for holdings.
    arguments
        holdings table
        prices table
    end

    result = holdings;
    if ~ismember("AssetClass", string(result.Properties.VariableNames))
        result.AssetClass = repmat("Unknown", height(result), 1);
    end
    result.LastPrice = zeros(height(result), 1);
    result.MarketValue = zeros(height(result), 1);
    result.CostValue = zeros(height(result), 1);
    result.UnrealizedPnL = zeros(height(result), 1);
    result.UnrealizedPnLPercent = zeros(height(result), 1);
    result.Allocation = zeros(height(result), 1);

    if height(result) == 0
        return
    end

    for idx = 1:height(result)
        match = strcmp(string(prices.Symbol), string(result.Symbol(idx)));
        if any(match)
            result.LastPrice(idx) = prices.LastPrice(find(match, 1, "first"));
        else
            result.LastPrice(idx) = NaN;
        end
    end

    result.MarketValue = result.Quantity .* result.LastPrice;
    result.CostValue = result.Quantity .* result.CostBasis;
    result.UnrealizedPnL = result.MarketValue - result.CostValue;
    result.UnrealizedPnLPercent = result.UnrealizedPnL ./ result.CostValue * 100;
    result.UnrealizedPnLPercent(result.CostValue == 0) = 0;

    totalValue = sum(result.MarketValue, "omitnan");
    if totalValue > 0
        result.Allocation = result.MarketValue ./ totalValue;
    end
end
