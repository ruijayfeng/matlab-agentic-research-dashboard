classdef TestCrossAssetPanel < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function crossAssetUniverseContainsOnlyExternalAssets(testCase)
            symbols = crypto.assets.crossAssetSymbols();

            testCase.verifyTrue(any(strcmp(symbols, "SPY")));
            testCase.verifyTrue(any(strcmp(symbols, "QQQ")));
            testCase.verifyTrue(any(strcmp(symbols, "GLD")));
            testCase.verifyFalse(any(strcmp(symbols, "BTCUSDT")));
            testCase.verifyFalse(any(strcmp(symbols, "ETHUSDT")));
            testCase.verifyFalse(any(strcmp(symbols, "SOLUSDT")));
        end
    end
end
