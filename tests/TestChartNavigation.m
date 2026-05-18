classdef TestChartNavigation < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function normalizeWindowClampsStartAndSize(testCase)
            [startIndex, windowSize, maxStart] = crypto.chart.normalizeWindow(100, 200, 50);

            testCase.verifyEqual(startIndex, 1);
            testCase.verifyEqual(windowSize, 100);
            testCase.verifyEqual(maxStart, 1);
        end

        function panWindowMovesAndClamps(testCase)
            [startIndex, windowSize] = crypto.chart.panWindow(500, 390, 100, 50);

            testCase.verifyEqual(startIndex, 401);
            testCase.verifyEqual(windowSize, 100);
        end

        function zoomInKeepsCenterNearStable(testCase)
            [startIndex, windowSize] = crypto.chart.zoomWindow(500, 201, 100, -1, 0.5);

            testCase.verifyLessThan(windowSize, 100);
            oldCenter = 201 + 99 * 0.5;
            newCenter = startIndex + (windowSize - 1) * 0.5;
            testCase.verifyLessThan(abs(newCenter - oldCenter), 2);
        end

        function zoomOutGrowsWindowAndClampsToHistory(testCase)
            [startIndex, windowSize] = crypto.chart.zoomWindow(80, 20, 50, 4, 0.5);

            testCase.verifyEqual(windowSize, 80);
            testCase.verifyEqual(startIndex, 1);
        end
    end
end
