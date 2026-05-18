classdef TestAnalysis < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function summarizeMarketDetectsBullishMomentum(testCase)
            tickers = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"], [70000; 3000; 180], [2.5; 1.2; -0.5], ...
                [1000000; 900000; 800000], [71000; 3050; 185], [68000; 2920; 175], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = table((datetime(2026, 1, 1) + hours(0:39))', ...
                (100:139)', (101:140)', (99:138)', (100.5:139.5)', (1000:1039)', ...
                'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume'});
            enriched = crypto.indicators.enrichCandles(candles);

            summary = crypto.analysis.summarizeMarket(tickers, enriched, "BTCUSDT");

            testCase.verifyTrue(contains(summary.Text, "BTCUSDT"));
            testCase.verifyEqual(summary.Trend, "bullish");
            testCase.verifyTrue(contains(summary.Text, "RSI"));
        end

        function buildContextReturnsPortfolioRiskAndCrossAssetState(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.6; 3; 20; 8; 5; 10], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));

            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            testCase.verifyEqual(context.Version, "ai-analysis-context-v1");
            testCase.verifyTrue(istable(context.MarketSnapshot));
            testCase.verifyTrue(istable(context.TechnicalState));
            testCase.verifyTrue(istable(context.Correlation.Matrix));
            testCase.verifyTrue(istable(context.RiskContributions));
            testCase.verifyTrue(any(strcmp(context.Signals, "ConcentrationRisk")));
            testCase.verifyTrue(isfield(context.LLMPayload, "riskContributions"));
            testCase.verifyGreaterThanOrEqual(height(context.RiskContributions), 6);
        end

        function analyzeContextReturnsLocalRulesNarrative(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            result = crypto.analysis.analyzeContext(context);

            testCase.verifyEqual(result.Provider, "local-rules");
            testCase.verifyTrue(contains(result.Text, "AI 分析"));
            testCase.verifyTrue(any(contains(result.Highlights, "集中度")));
            testCase.verifyTrue(isfield(result, "LLMAdapter"));
            testCase.verifyEqual(result.LLMAdapter.Status, "reserved");
        end

        function deepSeekMessagesIncludeStructuredContext(testCase)
            context = struct();
            context.LLMPayload = struct("version", "ai-analysis-context-v1", ...
                "universe", ["BTCUSDT"; "ETHUSDT"], ...
                "signals", "ConcentrationRisk", ...
                "averageCorrelation", 0.72);

            messages = crypto.analysis.deepSeekMessages(context);

            testCase.verifyEqual(messages(1).role, "system");
            testCase.verifyEqual(messages(2).role, "user");
            testCase.verifyTrue(contains(messages(2).content, "ai-analysis-context-v1"));
            testCase.verifyTrue(contains(messages(2).content, "ConcentrationRisk"));
        end

        function deepSeekAnalyzeContextFallsBackWhenKeyMissing(testCase)
            context = struct("LLMPayload", struct("version", "ai-analysis-context-v1"));

            result = crypto.analysis.deepSeekAnalyzeContext(context, "");

            testCase.verifyEqual(result.Provider, "local-rules");
            testCase.verifyTrue(contains(result.Text, "DeepSeek 不可用"));
            testCase.verifyEqual(result.LLMAdapter.Status, "missing-api-key");
        end

        function formatContextSnapshotShowsMatlabEvidence(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            lines = crypto.analysis.formatContextSnapshot(context);

            testCase.verifyTrue(any(contains(lines, "MATLAB 计算快照")));
            testCase.verifyTrue(any(contains(lines, "最大风险贡献")));
            testCase.verifyTrue(any(contains(lines, "加密资产风险贡献")));
            testCase.verifyTrue(any(contains(lines, "平均相关性")));
            testCase.verifyTrue(any(contains(lines, "信号")));
        end

        function buildStrategyScoresReturnsMultiStrategyCard(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            scores = crypto.analysis.buildStrategyScores(context, candles);

            expectedColumns = ["Symbol", "PriceActionScore", "TrendScore", "MeanReversionScore", ...
                "CrossAssetScore", "PortfolioImpactScore", "ValuationScore", "CompositeScore", "CompositeView"];
            testCase.verifyTrue(all(ismember(expectedColumns, string(scores.Properties.VariableNames))));
            testCase.verifyEqual(height(scores), 6);
            testCase.verifyTrue(all(scores.CompositeScore >= -100 & scores.CompositeScore <= 100));
            testCase.verifyTrue(any(strcmp(scores.CompositeView, "偏多")));
            testCase.verifyTrue(any(strcmp(scores.Symbol, "QQQ") & scores.ValuationScore < 0));
        end

        function evidenceFormattersReturnChineseBlocks(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            holdingLines = crypto.analysis.formatHoldingImpact(context);
            linkageLines = crypto.analysis.formatMarketLinkage(context);

            testCase.verifyTrue(any(contains(holdingLines, "持仓影响")));
            testCase.verifyTrue(any(contains(holdingLines, "风险贡献")));
            testCase.verifyTrue(any(contains(linkageLines, "市场联动")));
            testCase.verifyTrue(any(contains(linkageLines, "相关性")));
        end

        function stressPortfolioReturnsScenarioImpact(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            scenario = struct("BTCUSDT", -0.05, "QQQ", -0.03, "GLD", 0.02);
            stress = crypto.analysis.stressPortfolio(context, scenario);

            testCase.verifyTrue(isfield(stress, "ScenarioName"));
            testCase.verifyTrue(isfield(stress, "TotalShockPnL"));
            testCase.verifyTrue(isfield(stress, "AssetImpact"));
            testCase.verifyEqual(height(stress.AssetImpact) >= 3, true);
            testCase.verifyLessThan(stress.TotalShockPnL, 0);
        end

        function stressResultCanBeAttachedToContext(testCase)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = testCase.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);

            stress = crypto.analysis.stressPortfolio(context, struct("BTCUSDT", -0.05));
            context.StressResult = stress;
            context.LLMPayload.stressResult = stress;
            messages = crypto.analysis.deepSeekMessages(context);

            testCase.verifyTrue(contains(messages(2).content, "stressResult"));
        end
    end

    methods (Static, Access = private)
        function candlesBySymbol = sampleCandleStruct(symbols)
            candlesBySymbol = struct();
            baseTime = (datetime(2026, 1, 1) + days(0:79))';
            for idx = 1:numel(symbols)
                symbol = symbols(idx);
                drift = 0.002 * idx;
                wave = sin((1:80)' / (4 + idx)) * idx;
                close = 100 + idx * 20 + cumsum(ones(80, 1) * drift * 100 + wave * 0.08);
                if symbol == "GLD"
                    close = 220 + cumsum(cos((1:80)' / 5) * 0.12);
                end
                open = close .* 0.995;
                high = max(open, close) .* 1.01;
                low = min(open, close) .* 0.99;
                volume = (1000:1079)' * idx;
                raw = table(baseTime, open, high, low, close, volume, ...
                    'VariableNames', {'OpenTime', 'Open', 'High', 'Low', 'Close', 'Volume'});
                field = matlab.lang.makeValidName(char(symbol));
                candlesBySymbol.(field) = crypto.indicators.enrichCandles(raw);
            end
        end
    end
end
