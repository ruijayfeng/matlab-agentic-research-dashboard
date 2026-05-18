function summary = summarizePortfolio(positions)
%SUMMARIZEPORTFOLIO Compute portfolio-level totals and concentration.
    summary = struct( ...
        "TotalValue", 0, ...
        "TotalCost", 0, ...
        "TotalPnL", 0, ...
        "TotalPnLPercent", 0, ...
        "LargestSymbol", "", ...
        "LargestAllocation", 0, ...
        "InvestedValue", 0, ...
        "CashValue", 0);

    if isempty(positions) || height(positions) == 0
        return
    end

    values = positions.MarketValue;
    costs = positions.CostValue;
    summary.TotalValue = sum(values, "omitnan");
    summary.TotalCost = sum(costs, "omitnan");
    summary.TotalPnL = sum(positions.UnrealizedPnL, "omitnan");
    if summary.TotalCost > 0
        summary.TotalPnLPercent = summary.TotalPnL / summary.TotalCost * 100;
    end

    [largestAllocation, idx] = max(positions.Allocation);
    if ~isempty(idx) && ~isnan(largestAllocation)
        summary.LargestSymbol = string(positions.Symbol(idx));
        summary.LargestAllocation = largestAllocation;
    end

    isCash = strcmpi(string(positions.AssetClass), "Cash");
    summary.CashValue = sum(values(isCash), "omitnan");
    summary.InvestedValue = sum(values(~isCash), "omitnan");
end
