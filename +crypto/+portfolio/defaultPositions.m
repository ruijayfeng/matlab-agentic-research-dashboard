function positions = defaultPositions()
%DEFAULTPOSITIONS Initial portfolio rows. AssetClass keeps the model extensible.
    assets = crypto.assets.activeUniverse();
    positions = table(assets.Symbol, assets.AssetClass, zeros(height(assets), 1), zeros(height(assets), 1), ...
        'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
    demo = table( ...
        ["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"; "USDT"], ...
        [0.18; 2.4; 45; 18; 10; 22; 8000], ...
        [65000; 2800; 145; 505; 430; 195; 1], ...
        'VariableNames', {'Symbol', 'Quantity', 'CostBasis'});
    for idx = 1:height(demo)
        row = strcmp(string(positions.Symbol), demo.Symbol(idx));
        if any(row)
            positions.Quantity(row) = demo.Quantity(idx);
            positions.CostBasis(row) = demo.CostBasis(idx);
        end
    end
end
