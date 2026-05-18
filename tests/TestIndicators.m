classdef TestIndicators < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function movingAverageReturnsTrailingMean(testCase)
            prices = [1; 2; 3; 4; 5];

            ma = crypto.indicators.movingAverage(prices, 3);

            testCase.verifyTrue(all(isnan(ma(1:2))));
            testCase.verifyEqual(ma(3:end), [2; 3; 4], "AbsTol", 1e-12);
        end

        function rsiShowsStrongUptrend(testCase)
            prices = (1:20)';

            values = crypto.indicators.rsi(prices, 14);

            testCase.verifyGreaterThan(values(end), 99);
        end

        function macdHasExpectedShape(testCase)
            prices = (1:40)';

            [line, signal, histogram] = crypto.indicators.macd(prices, 12, 26, 9);

            testCase.verifySize(line, size(prices));
            testCase.verifySize(signal, size(prices));
            testCase.verifySize(histogram, size(prices));
            testCase.verifyGreaterThan(line(end), 0);
        end

        function enrichCandlesAddsTechnicalColumns(testCase)
            candles = table((datetime(2026, 1, 1) + hours(0:39))', ...
                (100:139)', (101:140)', (99:138)', (100.5:139.5)', (1000:1039)', ...
                'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume'});

            enriched = crypto.indicators.enrichCandles(candles);

            testCase.verifyTrue(all(ismember(["MA20", "MACD", "MACDSignal", "MACDHistogram", "RSI14", "Return"], string(enriched.Properties.VariableNames))));
            testCase.verifyGreaterThan(enriched.RSI14(end), 99);
        end
    end
end
