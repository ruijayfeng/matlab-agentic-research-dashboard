function stress = stressPortfolio(context, shockMap)
%STRESSPORTFOLIO Project portfolio impact under price shocks.
    arguments
        context struct
        shockMap struct
    end

    stress = struct();
    stress.ScenarioName = "自定义冲击";
    stress.AssetImpact = table(strings(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), ...
        'VariableNames', {'Symbol', 'ShockPct', 'MarketValue', 'ShockPnL', 'NewMarketValue'});

    if ~isfield(context, 'Portfolio') || isempty(context.Portfolio) || height(context.Portfolio) == 0
        stress.TotalShockPnL = 0;
        stress.TotalShockPnLPercent = 0;
        return
    end

    totalCurrent = 0;
    totalShockPnL = 0;
    for idx = 1:height(context.Portfolio)
        row = context.Portfolio(idx, :);
        symbol = string(row.Symbol);
        if symbol == "USDT"
            shockPct = 0;
        elseif isfield(shockMap, matlab.lang.makeValidName(char(symbol)))
            shockPct = shockMap.(matlab.lang.makeValidName(char(symbol)));
        else
            shockPct = 0;
        end
        marketValue = row.Quantity * row.LastPrice;
        shockPnL = marketValue * shockPct;
        newValue = marketValue + shockPnL;
        totalCurrent = totalCurrent + marketValue;
        totalShockPnL = totalShockPnL + shockPnL;
        stress.AssetImpact = [stress.AssetImpact; table(symbol, shockPct, marketValue, shockPnL, newValue, ...
            'VariableNames', stress.AssetImpact.Properties.VariableNames)]; %#ok<AGROW>
    end
    stress.TotalShockPnL = totalShockPnL;
    stress.TotalShockPnLPercent = totalShockPnL / max(totalCurrent, eps) * 100;
    stress.TotalCurrentValue = totalCurrent;
    stress.TotalNewValue = totalCurrent + totalShockPnL;
    stress.AssetImpact = sortrows(stress.AssetImpact, "ShockPnL", "ascend");
end
