classdef TestPortfolio < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function calculateHoldingsReturnsPnlAndAllocation(testCase)
            holdings = table(["BTCUSDT"; "ETHUSDT"], ["Crypto"; "Crypto"], [0.5; 2], [60000; 2500], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            prices = table(["BTCUSDT"; "ETHUSDT"], [70000; 3000], ...
                'VariableNames', {'Symbol', 'LastPrice'});

            result = crypto.portfolio.calculateHoldings(holdings, prices);

            testCase.verifyEqual(result.MarketValue, [35000; 6000], "AbsTol", 1e-9);
            testCase.verifyEqual(result.UnrealizedPnL, [5000; 1000], "AbsTol", 1e-9);
            testCase.verifyEqual(sum(result.Allocation), 1, "AbsTol", 1e-12);
        end

        function cashPositionUsesSyntheticUsdtPrice(testCase)
            tickers = table(["BTCUSDT"], 70000, 'VariableNames', {'Symbol', 'LastPrice'});
            prices = crypto.portfolio.priceTableWithCash(tickers);
            holdings = table(["USDT"], ["Cash"], 1000, 1, ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});

            result = crypto.portfolio.calculateHoldings(holdings, prices);

            testCase.verifyEqual(result.LastPrice, 1);
            testCase.verifyEqual(result.MarketValue, 1000);
            testCase.verifyEqual(result.UnrealizedPnL, 0);
        end

        function summarizePortfolioReportsTotalsAndConcentration(testCase)
            holdings = table(["BTCUSDT"; "USDT"], ["Crypto"; "Cash"], [0.5; 1000], [60000; 1], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            prices = table(["BTCUSDT"; "USDT"], [70000; 1], ...
                'VariableNames', {'Symbol', 'LastPrice'});
            result = crypto.portfolio.calculateHoldings(holdings, prices);

            summary = crypto.portfolio.summarizePortfolio(result);

            testCase.verifyEqual(summary.TotalValue, 36000, "AbsTol", 1e-9);
            testCase.verifyEqual(summary.TotalPnL, 5000, "AbsTol", 1e-9);
            testCase.verifyEqual(summary.LargestSymbol, "BTCUSDT");
            testCase.verifyEqual(summary.CashValue, 1000, "AbsTol", 1e-9);
        end

        function riskNarrativeFlagsConcentration(testCase)
            summary = struct("TotalValue", 100, "TotalCost", 80, "TotalPnL", 20, "TotalPnLPercent", 25, ...
                "LargestSymbol", "BTCUSDT", "LargestAllocation", 0.75, "InvestedValue", 98, "CashValue", 2);

            lines = crypto.portfolio.riskNarrative(summary);

            testCase.verifyTrue(any(contains(lines, "Concentration risk")));
            testCase.verifyTrue(any(contains(lines, "cash buffer is below 5%")));
            testCase.verifyTrue(any(contains(lines, "unrealized gain is above 10%")));
        end

        function emptyHoldingsReturnsExpectedColumns(testCase)
            holdings = table(strings(0, 1), zeros(0, 1), zeros(0, 1), ...
                'VariableNames', {'Symbol', 'Quantity', 'CostBasis'});
            prices = table(["BTCUSDT"], 70000, 'VariableNames', {'Symbol', 'LastPrice'});

            result = crypto.portfolio.calculateHoldings(holdings, prices);

            testCase.verifyEqual(height(result), 0);
            testCase.verifyTrue(all(ismember(["MarketValue", "UnrealizedPnL", "Allocation"], string(result.Properties.VariableNames))));
        end

        function defaultPositionsIncludeDemoHoldings(testCase)
            positions = crypto.portfolio.defaultPositions();

            testCase.verifyTrue(any(positions.Quantity > 0));
            testCase.verifyTrue(any(strcmp(positions.Symbol, "BTCUSDT") & positions.Quantity > 0));
            testCase.verifyTrue(any(strcmp(positions.Symbol, "USDT") & positions.Quantity > 0));
        end

        function holdingsRoundTripThroughCsv(testCase)
            positions = table(["BTCUSDT"; "SPY"; "USDT"], ["Crypto"; "US Equity"; "Cash"], [0.2; 10; 5000], [65000; 500; 1], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            outputPath = fullfile(tempdir, "crypto_dashboard_holdings_test.csv");
            cleanup = onCleanup(@() TestPortfolio.deleteIfExists(outputPath));

            crypto.portfolio.writePositions(positions, outputPath);
            loaded = crypto.portfolio.readPositions(outputPath);

            testCase.verifyEqual(loaded.Symbol, positions.Symbol);
            testCase.verifyEqual(loaded.AssetClass, positions.AssetClass);
            testCase.verifyEqual(loaded.Quantity, positions.Quantity, "AbsTol", 1e-12);
            testCase.verifyEqual(loaded.CostBasis, positions.CostBasis, "AbsTol", 1e-12);
        end

        function genericTableReaderSupportsCsv(testCase)
            data = table(["BTCUSDT"; "QQQ"], [1; 2], 'VariableNames', {'Symbol', 'Value'});
            pathName = fullfile(tempdir, "crypto_dashboard_table_test.csv");
            cleanup = onCleanup(@() TestPortfolio.deleteIfExists(pathName));
            writetable(data, pathName);

            loaded = crypto.export.readTable(pathName);

            testCase.verifyEqual(loaded.Symbol, data.Symbol);
            testCase.verifyEqual(loaded.Value, data.Value);
        end

        function appendPositionAddsNormalizedRow(testCase)
            positions = table(["BTCUSDT"], ["Crypto"], 0.2, 65000, ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});

            result = crypto.portfolio.appendPosition(positions, "QQQ", "US Equity");

            testCase.verifyEqual(height(result), 2);
            testCase.verifyEqual(result.Symbol(end), "QQQ");
            testCase.verifyEqual(result.AssetClass(end), "US Equity");
            testCase.verifyEqual(result.Quantity(end), 0);
            testCase.verifyEqual(result.CostBasis(end), 0);
        end
    end

    methods (Static, Access = private)
        function deleteIfExists(path)
            if isfile(path)
                delete(path);
            end
        end
    end
end
