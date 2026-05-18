classdef TestAssets < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function universeContainsLiveCryptoAndFutureAssets(testCase)
            assets = crypto.assets.universe();

            testCase.verifyTrue(all(ismember(["BTCUSDT", "ETHUSDT", "SOLUSDT"], assets.Symbol)));
            testCase.verifyTrue(any(strcmp(assets.AssetClass, "China Equity")));
            testCase.verifyTrue(any(strcmp(assets.AssetClass, "US Equity")));
            testCase.verifyTrue(any(strcmp(assets.AssetClass, "Commodity")));
        end

        function liveSymbolsOnlyReturnsImplementedBinanceRows(testCase)
            symbols = crypto.assets.liveSymbols();

            testCase.verifyEqual(symbols, ["BTCUSDT"; "ETHUSDT"; "SOLUSDT"]);
        end

        function activeUniverseAlwaysContainsBaseRows(testCase)
            assets = crypto.assets.activeUniverse();

            testCase.verifyTrue(all(ismember(["BTCUSDT", "ETHUSDT", "SOLUSDT", "USDT"], assets.Symbol)));
        end

        function chartSymbolsContainsLiveCrypto(testCase)
            symbols = crypto.assets.chartSymbols();

            testCase.verifyTrue(all(ismember(["BTCUSDT", "ETHUSDT", "SOLUSDT"], symbols)));
            testCase.verifyFalse(any(strcmp(symbols, "USDT")));
            testCase.verifyFalse(any(strcmp(symbols, "SPY")));
            testCase.verifyFalse(any(strcmp(symbols, "QQQ")));
            testCase.verifyFalse(any(strcmp(symbols, "GLD")));
        end

        function crossAssetSymbolsExcludesCrypto(testCase)
            symbols = crypto.assets.crossAssetSymbols();

            testCase.verifyFalse(any(strcmp(symbols, "BTCUSDT")));
            testCase.verifyFalse(any(strcmp(symbols, "ETHUSDT")));
            testCase.verifyFalse(any(strcmp(symbols, "SOLUSDT")));
        end
    end
end
