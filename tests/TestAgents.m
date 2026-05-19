classdef TestAgents < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function runResearchAgentsReturnsVisibleAgentCluster(testCase)
            context = TestAgents.sampleContext();

            run = crypto.agents.runResearchAgents(context);

            testCase.verifyTrue(isfield(run, "RunId"));
            testCase.verifyEqual(run.ContextVersion, "ai-analysis-context-v1");
            testCase.verifyTrue(isfield(run, "AgentResults"));
            testCase.verifyEqual(numel(run.AgentResults), 5);
            testCase.verifyTrue(isfield(run, "Consensus"));
            testCase.verifyTrue(isfield(run, "Disagreements"));
            testCase.verifyTrue(isfield(run, "ActionWatchlist"));
            testCase.verifyTrue(isfield(run, "EvidenceLog"));
            testCase.verifyTrue(isfield(run, "IntegratedRecommendation"));
            testCase.verifyNotEmpty(run.IntegratedRecommendation);

            required = crypto.agents.requiredFields();
            for idx = 1:numel(run.AgentResults)
                result = run.AgentResults(idx);
                testCase.verifyTrue(all(isfield(result, required)));
                testCase.verifyGreaterThanOrEqual(result.Confidence, 0);
                testCase.verifyLessThanOrEqual(result.Confidence, 1);
                testCase.verifyNotEmpty(result.Headline);
                testCase.verifyNotEmpty(result.Evidence);
            end
        end

        function dataQualityAgentWarnsWhenContextIsIncomplete(testCase)
            context = struct("Version", "ai-analysis-context-v1");

            result = crypto.agents.dataQualityAgent(context);

            testCase.verifyEqual(result.Name, "DataQualityAgent");
            testCase.verifyEqual(result.Status, "warning");
            testCase.verifyLessThan(result.Confidence, 0.7);
            testCase.verifyTrue(any(contains(result.Risks, "缺失")));
        end

        function criticAgentFlagsBullishRiskConflict(testCase)
            technical = crypto.agents.makeResult("TechnicalAgent", "Technical market analysis", ...
                "completed", 0.86, "趋势偏强，继续偏多", ["BTC 高于 MA20"], strings(0, 1), "继续持有");
            risk = crypto.agents.makeResult("PortfolioRiskAgent", "Portfolio risk analysis", ...
                "warning", 0.82, "BTC 风险贡献偏高，集中度较高", ["BTC 风险贡献 72%"], ["集中度较高"], "降低集中度");
            data = crypto.agents.makeResult("DataQualityAgent", "Data quality review", ...
                "completed", 0.9, "数据可用", ["数据完整"], strings(0, 1), "继续分析");

            result = crypto.agents.criticAgent(struct(), [data, technical, risk]);

            testCase.verifyEqual(result.Name, "CriticAgent");
            testCase.verifyEqual(result.Status, "warning");
            testCase.verifyTrue(any(contains(result.Risks, "冲突")));
            testCase.verifyTrue(contains(result.Headline, "降级"));
        end

        function consensusIncludesWatchlistAndEvidenceLog(testCase)
            context = TestAgents.sampleContext();
            run = crypto.agents.runResearchAgents(context);

            testCase.verifyGreaterThan(numel(run.Consensus), 0);
            testCase.verifyGreaterThan(numel(run.ActionWatchlist), 0);
            testCase.verifyGreaterThan(numel(run.EvidenceLog), 0);
            testCase.verifyTrue(any(contains(run.EvidenceLog, "TechnicalAgent")));
        end

        function displayFormattersSeparateFlowFromCards(testCase)
            context = TestAgents.sampleContext();
            run = crypto.agents.runResearchAgents(context);

            flowLines = crypto.agents.formatFlow(run);
            cardLines = crypto.agents.formatCards(run);

            testCase.verifyTrue(any(contains(flowLines, "DataQualityAgent")));
            testCase.verifyTrue(any(contains(flowLines, "->")));
            testCase.verifyTrue(any(contains(cardLines, "技术面研究员")));
            testCase.verifyTrue(any(contains(cardLines, "我看到")));
            testCase.verifyTrue(any(contains(cardLines, "我的建议")));
            testCase.verifyGreaterThan(numel(cardLines), numel(flowLines));
        end

        function integratedRecommendationSummarizesAllAgentViews(testCase)
            context = TestAgents.sampleContext();
            run = crypto.agents.runResearchAgents(context);

            text = crypto.agents.formatIntegratedRecommendation(run);

            testCase.verifyTrue(any(contains(text, "综合建议")));
            testCase.verifyTrue(any(contains(text, "市场判断")));
            testCase.verifyTrue(any(contains(text, "仓位建议")));
            testCase.verifyTrue(any(contains(text, "可以加仓")));
            testCase.verifyTrue(any(contains(text, "需要减仓")));
            testCase.verifyTrue(any(contains(text, "重点观察")));
            testCase.verifyFalse(any(contains(text, "warning Agent")));
            testCase.verifyFalse(any(contains(text, "置信度")));
        end

        function agentCardsReadLikeResearchDeskRoles(testCase)
            context = TestAgents.sampleContext();
            run = crypto.agents.runResearchAgents(context);

            cards = crypto.agents.formatCards(run);

            testCase.verifyTrue(any(contains(cards, "技术面研究员")));
            testCase.verifyTrue(any(contains(cards, "组合风控员")));
            testCase.verifyTrue(any(contains(cards, "跨资产联动研究员")));
            testCase.verifyTrue(any(contains(cards, "反方审查员")));
            testCase.verifyTrue(any(contains(cards, "我看到")));
            testCase.verifyTrue(any(contains(cards, "我的建议")));
            testCase.verifyFalse(any(contains(cards, "Confidence")));
            testCase.verifyFalse(any(contains(cards, "Evidence:")));
        end
    end

    methods (Static, Access = private)
        function context = sampleContext()
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            tickers = table(symbols', [70000; 3000; 180; 520; 440; 210], [3.2; 2.1; 5.8; 0.6; 0.9; -0.2], ...
                [1; 1; 1; 1; 1; 1] * 1000, [1; 1; 1; 1; 1; 1] * 100000, ...
                [71000; 3050; 190; 525; 445; 212], [68000; 2920; 170; 515; 435; 208], ...
                'VariableNames', {'Symbol', 'LastPrice', 'PriceChangePercent', 'Volume', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            candles = TestAgents.sampleCandleStruct(symbols);
            portfolio = table(["BTCUSDT"; "ETHUSDT"; "SOLUSDT"; "SPY"; "QQQ"; "GLD"], ...
                ["Crypto"; "Crypto"; "Crypto"; "US Equity"; "US Equity"; "Commodity"], ...
                [0.8; 1; 5; 2; 1; 1], [60000; 2500; 150; 500; 420; 200], ...
                'VariableNames', {'Symbol', 'AssetClass', 'Quantity', 'CostBasis'});
            portfolio = crypto.portfolio.calculateHoldings(portfolio, tickers(:, {'Symbol', 'LastPrice'}));
            context = crypto.analysis.buildContext(tickers, candles, portfolio);
        end

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
