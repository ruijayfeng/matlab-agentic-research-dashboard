function diagnoseCryptoDashboard()
%DIAGNOSECRYPTODASHBOARD Run data and analysis steps without opening the UI.
    fprintf("Step 1: symbols\n");
    symbols = crypto.data.defaultSymbols();
    disp(symbols);

    fprintf("Step 2: 24h tickers\n");
    tickers = crypto.data.fetch24hTickers(symbols);
    disp(tickers);

    fprintf("Step 3: BTCUSDT 1h candles\n");
    candles = crypto.data.fetchKlines("BTCUSDT", "1h", 50);
    disp(candles(1:min(5, height(candles)), :));

    fprintf("Step 4: indicators\n");
    enriched = crypto.indicators.enrichCandles(candles);
    disp(enriched(max(1, height(enriched)-4):height(enriched), {'OpenTime', 'Close', 'MA20', 'MACDHistogram', 'RSI14'}));

    fprintf("Step 5: analysis\n");
    summary = crypto.analysis.summarizeMarket(tickers, enriched, "BTCUSDT");
    disp(summary.Text);

    fprintf("Step 6: AI Analysis provider\n");
    try
        assets = crypto.assets.activeUniverse();
        allTickers = crypto.data.latestPrices(assets);
        symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
        candlesBySymbol = struct();
        for idx = 1:numel(symbols)
            symbol = symbols(idx);
            try
                daily = crypto.data.fetchCandles(symbol, "1d", 120);
                candlesBySymbol.(matlab.lang.makeValidName(char(symbol))) = crypto.indicators.enrichCandles(daily);
            catch
            end
        end
        positions = crypto.portfolio.defaultPositions();
        prices = crypto.portfolio.priceTableWithCash(allTickers);
        portfolio = crypto.portfolio.calculateHoldings(positions, prices);
        context = crypto.analysis.buildContext(allTickers, candlesBySymbol, portfolio);
        aiResult = crypto.analysis.deepSeekAnalyzeContext(context);
        fprintf("Provider: %s\n", aiResult.Provider);
        fprintf("Adapter status: %s\n", aiResult.LLMAdapter.Status);
        disp(extractBefore(string(aiResult.Text) + newline, newline));
    catch err
        fprintf("AI Analysis diagnostic skipped: %s\n", err.message);
    end

    fprintf("Diagnosis finished.\n");
end
