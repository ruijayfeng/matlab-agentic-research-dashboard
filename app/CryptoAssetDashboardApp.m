classdef CryptoAssetDashboardApp < handle
    properties
        Figure matlab.ui.Figure
        AssetDropDown matlab.ui.control.DropDown
        IntervalDropDown matlab.ui.control.DropDown
        VisibleCandlesDropDown matlab.ui.control.DropDown
        HistorySlider matlab.ui.control.Slider
        LatestButton matlab.ui.control.Button
        AutoRefreshCheckBox matlab.ui.control.CheckBox
        RefreshSecondsDropDown matlab.ui.control.DropDown
        RefreshButton matlab.ui.control.Button
        ResetViewButton matlab.ui.control.Button
        AnalyzeAiButton matlab.ui.control.Button
        ExportButton matlab.ui.control.Button
        ImportHoldingsButton matlab.ui.control.Button
        ExportHoldingsButton matlab.ui.control.Button
        AddHoldingButton matlab.ui.control.Button
        RemoveHoldingButton matlab.ui.control.Button
        StatusLabel matlab.ui.control.Label
        MarketTable matlab.ui.control.Table
        HoldingsInputTable matlab.ui.control.Table
        PortfolioTable matlab.ui.control.Table
        PriceAxes matlab.ui.control.UIAxes
        IndicatorAxes matlab.ui.control.UIAxes
        CrossAssetDropDown matlab.ui.control.DropDown
        CrossAssetPriceAxes matlab.ui.control.UIAxes
        CrossAssetIndicatorAxes matlab.ui.control.UIAxes
        AllocationAxes matlab.ui.control.UIAxes
        AnalysisTextArea matlab.ui.control.TextArea
        HoldingImpactTextArea matlab.ui.control.TextArea
        MarketLinkageTextArea matlab.ui.control.TextArea
        StressTextArea matlab.ui.control.TextArea
        RiskContributionTable matlab.ui.control.Table
        StrategyScoreTable matlab.ui.control.Table
        PortfolioSummaryLabel matlab.ui.control.Label
        AgentCardsTextArea matlab.ui.control.TextArea
        IntegratedRecommendationTextArea matlab.ui.control.TextArea
        LatestTickers table
        LatestCandles table
        PortfolioPositions table
        LatestPortfolio table
        LatestSummary struct
        LatestAgentRun struct = struct()
        LatestAnalysisCandles struct = struct()
        LatestAnalysisContext struct = struct()
        LatestAnalysisResult struct = struct()
        LatestStressResult struct = struct()
        SelectedHoldingRow double = NaN
        RefreshTimer = []
        IsRefreshing logical = false
        VisibleCandleCount double = 100
        WindowStartIndex double = 1
        FollowLatest logical = true
        IsChartDragging logical = false
        DragStartX double = NaN
        DragStartWindowStart double = 1
    end

    methods
        function app = CryptoAssetDashboardApp()
            app.PortfolioPositions = crypto.portfolio.defaultPositions();
            app.buildUi();
            app.refreshData();
        end

        function delete(app)
            app.stopAutoRefresh();
        end

        function buildUi(app)
            app.Figure = uifigure("Name", "Crypto Asset Intelligence Dashboard", "Position", [60 60 1580 900]);
            app.Figure.CloseRequestFcn = @(~,~) app.closeApp();
            app.Figure.WindowScrollWheelFcn = @(~, event) app.onChartScroll(event);
            app.Figure.WindowButtonDownFcn = @(~,~) app.onChartMouseDown();
            app.Figure.WindowButtonMotionFcn = @(~,~) app.onChartMouseMove();
            app.Figure.WindowButtonUpFcn = @(~,~) app.onChartMouseUp();
            root = uigridlayout(app.Figure, [3 3]);
            root.RowHeight = {104, "1x", 160};
            root.ColumnWidth = {280, "1x", 420};
            root.Padding = [12 12 12 12];
            root.RowSpacing = 10;
            root.ColumnSpacing = 10;

            controls = uigridlayout(root, [3 14]);
            controls.Layout.Row = 1;
            controls.Layout.Column = [1 3];
            controls.ColumnWidth = {38, 110, 26, 82, 36, 82, 48, "1x", 62, 62, 70, 82, 66, 150};
            controls.RowHeight = {30, 30, 26};
            controls.RowSpacing = 6;
            controls.ColumnSpacing = 6;

            assetItems = cellstr(reshape(crypto.assets.chartSymbols(), 1, []));
            intervalItems = {'1m', '5m', '15m', '1h', '4h', '1d'};
            windowItems = {'20', '30', '50', '75', '100', '150', '200', '300', '500'};
            refreshItems = {'10', '30', '60'};
            assetLabel = uilabel(controls, "Text", "Coin");
            assetLabel.Layout.Row = 1;
            assetLabel.Layout.Column = 1;
            app.AssetDropDown = uidropdown(controls, "Items", assetItems, "Value", "BTCUSDT", "ValueChangedFcn", @(~,~) app.refreshData(true));
            app.AssetDropDown.Layout.Row = 1;
            app.AssetDropDown.Layout.Column = 2;
            intervalLabel = uilabel(controls, "Text", "TF");
            intervalLabel.Layout.Row = 1;
            intervalLabel.Layout.Column = 3;
            app.IntervalDropDown = uidropdown(controls, "Items", intervalItems, "Value", "1h", "ValueChangedFcn", @(~,~) app.refreshData(true));
            app.IntervalDropDown.Layout.Row = 1;
            app.IntervalDropDown.Layout.Column = 4;
            windowLabel = uilabel(controls, "Text", "Bars");
            windowLabel.Layout.Row = 1;
            windowLabel.Layout.Column = 5;
            app.VisibleCandlesDropDown = uidropdown(controls, "Items", windowItems, "Value", "100", "ValueChangedFcn", @(~,~) app.onVisibleWindowChanged());
            app.VisibleCandlesDropDown.Layout.Row = 1;
            app.VisibleCandlesDropDown.Layout.Column = 6;
            historyLabel = uilabel(controls, "Text", "History");
            historyLabel.Layout.Row = 1;
            historyLabel.Layout.Column = 7;
            app.HistorySlider = uislider(controls, "Limits", [1 2], "Value", 1, ...
                "ValueChangingFcn", @(~, event) app.onHistorySliderChanging(event), ...
                "ValueChangedFcn", @(~,~) app.onHistorySliderChanged());
            app.HistorySlider.Layout.Row = 1;
            app.HistorySlider.Layout.Column = [8 14];

            app.LatestButton = uibutton(controls, "Text", "Latest", "ButtonPushedFcn", @(~,~) app.setLatestView());
            app.LatestButton.Layout.Row = 2;
            app.LatestButton.Layout.Column = 1;
            app.AutoRefreshCheckBox = uicheckbox(controls, "Text", "Auto", "ValueChangedFcn", @(~,~) app.toggleAutoRefresh());
            app.AutoRefreshCheckBox.Layout.Row = 2;
            app.AutoRefreshCheckBox.Layout.Column = [2 3];
            secondsLabel = uilabel(controls, "Text", "Sec");
            secondsLabel.Layout.Row = 2;
            secondsLabel.Layout.Column = 4;
            app.RefreshSecondsDropDown = uidropdown(controls, "Items", refreshItems, "Value", "30", "ValueChangedFcn", @(~,~) app.restartAutoRefresh());
            app.RefreshSecondsDropDown.Layout.Row = 2;
            app.RefreshSecondsDropDown.Layout.Column = 5;
            app.RefreshButton = uibutton(controls, "Text", "Refresh", "ButtonPushedFcn", @(~,~) app.refreshData(false));
            app.RefreshButton.Layout.Row = 2;
            app.RefreshButton.Layout.Column = 6;
            app.ResetViewButton = uibutton(controls, "Text", "Reset", "ButtonPushedFcn", @(~,~) app.resetChartView());
            app.ResetViewButton.Layout.Row = 2;
            app.ResetViewButton.Layout.Column = 7;
            app.AnalyzeAiButton = uibutton(controls, "Text", "AI分析", "ButtonPushedFcn", @(~,~) app.runDeepSeekAnalysis());
            app.AnalyzeAiButton.Layout.Row = 2;
            app.AnalyzeAiButton.Layout.Column = 8;
            app.ExportButton = uibutton(controls, "Text", "Export", "ButtonPushedFcn", @(~,~) app.exportCurrentData());
            app.ExportButton.Layout.Row = 2;
            app.ExportButton.Layout.Column = 9;
            app.StatusLabel = uilabel(controls, "Text", "Ready", "HorizontalAlignment", "right");
            app.StatusLabel.Layout.Row = 2;
            app.StatusLabel.Layout.Column = [10 14];

            tip = uilabel(controls, "Text", "Binance Spot | Asia/Shanghai time | BTC / ETH / SOL", ...
                "FontSize", 11, "FontColor", [0.35 0.35 0.35]);
            tip.Layout.Row = 3;
            tip.Layout.Column = [1 14];

            leftPanel = uigridlayout(root, [2 1]);
            leftPanel.Layout.Row = 2;
            leftPanel.Layout.Column = 1;
            leftPanel.RowHeight = {"1x", 280};
            leftPanel.RowSpacing = 10;
            app.MarketTable = uitable(leftPanel);
            app.MarketTable.ColumnName = {'Symbol', 'Last', '24h %', 'Volume', 'High', 'Low'};

            holdingsPanel = uigridlayout(leftPanel, [4 1]);
            holdingsPanel.RowHeight = {24, 36, 30, "1x"};
            holdingsPanel.RowSpacing = 4;
            uilabel(holdingsPanel, "Text", "持仓录入", "FontWeight", "bold");
            uilabel(holdingsPanel, "Text", "在下表填写 Qty=持仓数量，Cost=买入均价；系统会自动计算市值、盈亏和风险贡献。", ...
                "FontSize", 11, "FontColor", [0.35 0.35 0.35]);
            holdingsButtons = uigridlayout(holdingsPanel, [1 4]);
            holdingsButtons.ColumnWidth = {"1x", "1x", "1x", "1x"};
            holdingsButtons.Padding = [0 0 0 0];
            app.ImportHoldingsButton = uibutton(holdingsButtons, "Text", "导入持仓", "ButtonPushedFcn", @(~,~) app.importHoldings());
            app.ExportHoldingsButton = uibutton(holdingsButtons, "Text", "导出持仓", "ButtonPushedFcn", @(~,~) app.exportHoldings());
            app.AddHoldingButton = uibutton(holdingsButtons, "Text", "新增行", "ButtonPushedFcn", @(~,~) app.addHoldingRow());
            app.RemoveHoldingButton = uibutton(holdingsButtons, "Text", "删除行", "ButtonPushedFcn", @(~,~) app.removeHoldingRow());
            app.HoldingsInputTable = uitable(holdingsPanel, ...
                "Data", app.PortfolioPositions, ...
                "ColumnEditable", [false false true true], ...
                "CellEditCallback", @(src,~) app.onPortfolioInputEdited(src), ...
                "CellSelectionCallback", @(~, event) app.onHoldingCellSelected(event));
            app.HoldingsInputTable.ColumnName = {'资产', '类别', '数量 Qty', '买入均价 Cost'};

            chartTabs = uitabgroup(root);
            chartTabs.Layout.Row = 2;
            chartTabs.Layout.Column = 2;

            cryptoTab = uitab(chartTabs, "Title", "Crypto Intraday");
            chartPanel = uigridlayout(cryptoTab, [2 1]);
            chartPanel.RowHeight = {"2x", "1x"};
            chartPanel.Padding = [6 6 6 6];
            chartPanel.RowSpacing = 8;
            app.PriceAxes = uiaxes(chartPanel);
            title(app.PriceAxes, "Price / MA20");
            app.IndicatorAxes = uiaxes(chartPanel);
            title(app.IndicatorAxes, "MACD / RSI");
            app.configureAxesInteraction(app.PriceAxes);
            app.configureAxesInteraction(app.IndicatorAxes);

            crossTab = uitab(chartTabs, "Title", "Cross-Asset Daily");
            crossPanel = uigridlayout(crossTab, [3 1]);
            crossPanel.RowHeight = {32, "2x", "1x"};
            crossPanel.Padding = [6 6 6 6];
            crossPanel.RowSpacing = 8;
            crossControls = uigridlayout(crossPanel, [1 4]);
            crossControls.ColumnWidth = {55, 110, "1x", 90};
            uilabel(crossControls, "Text", "Asset");
            crossItems = cellstr(reshape(crypto.assets.crossAssetSymbols(), 1, []));
            if isempty(crossItems)
                crossItems = {'NoData'};
            end
            app.CrossAssetDropDown = uidropdown(crossControls, "Items", crossItems, "Value", crossItems{1}, "ValueChangedFcn", @(~,~) app.renderCrossAssetCharts());
            uilabel(crossControls, "Text", "Daily data via Stooq cache", "FontColor", [0.35 0.35 0.35]);
            uibutton(crossControls, "Text", "Refresh", "ButtonPushedFcn", @(~,~) app.renderCrossAssetCharts(true));
            app.CrossAssetPriceAxes = uiaxes(crossPanel);
            title(app.CrossAssetPriceAxes, "Cross-Asset Price / MA20");
            app.CrossAssetIndicatorAxes = uiaxes(crossPanel);
            title(app.CrossAssetIndicatorAxes, "Cross-Asset MACD / RSI");
            app.configureAxesInteraction(app.CrossAssetPriceAxes);
            app.configureAxesInteraction(app.CrossAssetIndicatorAxes);

            aiTab = uitab(chartTabs, "Title", "AI分析");
            aiPanel = uigridlayout(aiTab, [8 2]);
            aiPanel.RowHeight = {28, 86, 86, 150, "2x", 76, 110, 120};
            aiPanel.ColumnWidth = {"1x", "1x"};
            aiPanel.Padding = [6 6 6 6];
            aiPanel.RowSpacing = 8;
            aiPanel.ColumnSpacing = 8;
            uilabel(aiPanel, "Text", "MATLAB 计算依据 + DeepSeek 持仓风险报告", "FontWeight", "bold");
            app.HoldingImpactTextArea = uitextarea(aiPanel, "Editable", "off");
            app.HoldingImpactTextArea.Layout.Row = 2;
            app.HoldingImpactTextArea.Layout.Column = 1;
            app.MarketLinkageTextArea = uitextarea(aiPanel, "Editable", "off");
            app.MarketLinkageTextArea.Layout.Row = 3;
            app.MarketLinkageTextArea.Layout.Column = 1;
            app.IntegratedRecommendationTextArea = uitextarea(aiPanel, "Editable", "off", "FontName", "Consolas", "FontSize", 13);
            app.IntegratedRecommendationTextArea.Layout.Row = 4;
            app.IntegratedRecommendationTextArea.Layout.Column = [1 2];
            app.AgentCardsTextArea = uitextarea(aiPanel, "Editable", "off", "FontName", "Consolas", "FontSize", 13);
            app.AgentCardsTextArea.Layout.Row = 5;
            app.AgentCardsTextArea.Layout.Column = [1 2];
            stressPanel = uigridlayout(aiPanel, [1 5]);
            stressPanel.Layout.Row = 6;
            stressPanel.Layout.Column = [1 2];
            stressPanel.ColumnWidth = {"1x", "1x", "1x", "1x", "2x"};
            stressPanel.Padding = [0 0 0 0];
            uibutton(stressPanel, "Text", "加密回撤", "ButtonPushedFcn", @(~,~) app.runStressScenario("crypto"));
            uibutton(stressPanel, "Text", "科技回撤", "ButtonPushedFcn", @(~,~) app.runStressScenario("tech"));
            uibutton(stressPanel, "Text", "共振下跌", "ButtonPushedFcn", @(~,~) app.runStressScenario("riskoff"));
            uibutton(stressPanel, "Text", "黄金避险", "ButtonPushedFcn", @(~,~) app.runStressScenario("gold"));
            app.StressTextArea = uitextarea(stressPanel, "Editable", "off", "Value", app.textAreaValue("压力测试：请选择情景。"));
            app.StrategyScoreTable = uitable(aiPanel);
            app.StrategyScoreTable.ColumnName = {'资产', '裸K', '趋势', '均值回归', '联动', '持仓影响', '估值', '综合分', '结论'};
            app.StrategyScoreTable.Layout.Row = 7;
            app.StrategyScoreTable.Layout.Column = [1 2];
            app.AnalysisTextArea = uitextarea(aiPanel, "Editable", "off", "FontName", "Consolas", "FontSize", 13);
            app.AnalysisTextArea.Layout.Row = 8;
            app.AnalysisTextArea.Layout.Column = 1;
            app.RiskContributionTable = uitable(aiPanel);
            app.RiskContributionTable.ColumnName = {'资产', '类别', '权重', '20日波动', '风险分数', '风险贡献'};
            app.RiskContributionTable.Layout.Row = 8;
            app.RiskContributionTable.Layout.Column = 2;
            chartTabs.SelectedTab = aiTab;

            rightPanel = uigridlayout(root, [3 1]);
            rightPanel.Layout.Row = 2;
            rightPanel.Layout.Column = 3;
            rightPanel.RowHeight = {26, 230, "1x"};
            rightPanel.RowSpacing = 8;
            app.PortfolioSummaryLabel = uilabel(rightPanel, "Text", "Portfolio: no positions", "FontWeight", "bold");
            app.AllocationAxes = uiaxes(rightPanel);
            title(app.AllocationAxes, "Asset Allocation");
            app.PortfolioTable = uitable(rightPanel);
            app.PortfolioTable.ColumnName = {'Symbol', 'Class', 'Qty', 'Last', 'Value', 'PnL', 'PnL %', 'Alloc'};

            notesValue = app.textAreaValue({ ...
                'Agent Workbench 资产池：BTCUSDT / ETHUSDT / SOLUSDT / SPY / QQQ / GLD。', ...
                '优先阅读“综合建议”：这里会直接给出市场判断、仓位动作、加仓/减仓方向和重点观察条件。', ...
                'Agent 集群按角色拆分输出：数据质检、技术面、组合风控、跨资产联动和反方审查。', ...
                '在左侧持仓表编辑 Qty 和 Cost 后刷新，组合风险、压力测试和 Agent 结论会同步更新。', ...
                '点击 AI分析 可调用 DeepSeek 生成中文报告；自动刷新只更新 MATLAB Agent 本地分析。'});
            notes = uitextarea(root, "Editable", "off", "Value", notesValue);
            notes.Layout.Row = 3;
            notes.Layout.Column = [1 3];
        end

        function refreshData(app, resetToLatest)
            if nargin < 2
                resetToLatest = false;
            end
            if app.IsRefreshing
                return
            end
            app.IsRefreshing = true;
            cleanup = onCleanup(@() app.finishRefresh());
            app.StatusLabel.Text = "Fetching Binance data...";
            cla(app.PriceAxes);
            cla(app.IndicatorAxes);
            drawnow;
            try
                app.StatusLabel.Text = "Fetching 24h tickers...";
                drawnow;
                app.LatestTickers = crypto.data.latestPrices(crypto.assets.activeUniverse());
                app.StatusLabel.Text = "Fetching candles...";
                drawnow;
                previousStart = app.WindowStartIndex;
                previousWasLatest = app.FollowLatest || resetToLatest;
                candles = crypto.data.fetchCandles(string(app.AssetDropDown.Value), string(app.IntervalDropDown.Value), 500);
                app.StatusLabel.Text = "Calculating indicators...";
                drawnow;
                app.LatestCandles = crypto.indicators.enrichCandles(candles);
                app.updateChartNavigationControls(previousStart, previousWasLatest);
                app.StatusLabel.Text = "Generating analysis...";
                drawnow;
                app.LatestSummary = crypto.analysis.summarizeMarket(app.LatestTickers, app.LatestCandles, string(app.AssetDropDown.Value));
                app.StatusLabel.Text = "Rendering dashboard...";
                drawnow;
                app.renderMarket();
                app.renderCharts();
                app.renderCrossAssetCharts();
                app.updatePortfolio();
                app.updateAiAnalysis(false);
                app.renderAnalysis();
                chinaNow = datetime('now', "TimeZone", "Asia/Shanghai", "Format", "HH:mm:ss");
                app.StatusLabel.Text = "Updated CN " + string(chinaNow);
            catch err
                app.StatusLabel.Text = "Error";
                report = getReport(err, 'extended', 'hyperlinks', 'off');
                disp(report);
                app.AnalysisTextArea.Value = app.textAreaValue(splitlines(string(report)));
            end
        end

        function renderMarket(app)
            displayTable = app.LatestTickers(:, {'Symbol', 'LastPrice', 'PriceChangePercent', 'QuoteVolume', 'HighPrice', 'LowPrice'});
            app.MarketTable.Data = displayTable;
        end

        function renderCharts(app)
            c = app.visibleCandles();
            if isempty(c) || height(c) == 0
                return
            end
            preserveView = app.IsChartDragging || ~app.FollowLatest;
            cla(app.PriceAxes);
            reset(app.PriceAxes);
            app.configureAxesInteraction(app.PriceAxes);
            validClose = ~isnan(c.Close) & ~isnan(c.Open) & ~isnan(c.High) & ~isnan(c.Low);
            app.drawCandles(app.PriceAxes, c(validClose, :));
            hold(app.PriceAxes, "on");
            legendHandles = gobjects(0);
            legendLabels = {};
            validMa = ~isnan(c.MA20);
            if any(validMa)
                maLine = plot(app.PriceAxes, datenum(c.OpenTime(validMa)), c.MA20(validMa), "Color", [0.95 0.65 0.1], "LineWidth", 1.2);
                legendHandles(end + 1) = maLine;
                legendLabels{end + 1} = 'MA20';
            end
            hold(app.PriceAxes, "off");
            grid(app.PriceAxes, "on");
            if ~isempty(legendHandles)
                legend(app.PriceAxes, legendHandles, legendLabels, "Location", "best", "AutoUpdate", "off");
            else
                legend(app.PriceAxes, "off");
            end
            title(app.PriceAxes, string(app.AssetDropDown.Value) + " " + string(app.IntervalDropDown.Value));
            xlabel(app.PriceAxes, "Time");
            ylabel(app.PriceAxes, "Price");

            cla(app.IndicatorAxes);
            reset(app.IndicatorAxes);
            app.configureAxesInteraction(app.IndicatorAxes);
            yyaxis(app.IndicatorAxes, "left");
            bar(app.IndicatorAxes, c.OpenTime, c.MACDHistogram, "FaceColor", [0.45 0.55 0.7], "EdgeColor", "none");
            hold(app.IndicatorAxes, "on");
            plot(app.IndicatorAxes, c.OpenTime, c.MACD, "Color", [0.1 0.35 0.75], "LineWidth", 1.1);
            plot(app.IndicatorAxes, c.OpenTime, c.MACDSignal, "Color", [0.85 0.25 0.1], "LineWidth", 1.1);
            hold(app.IndicatorAxes, "off");
            ylabel(app.IndicatorAxes, "MACD");
            yyaxis(app.IndicatorAxes, "right");
            plot(app.IndicatorAxes, c.OpenTime, c.RSI14, "LineWidth", 1.2);
            yline(app.IndicatorAxes, 70, "--");
            yline(app.IndicatorAxes, 30, "--");
            ylabel(app.IndicatorAxes, "RSI");
            ylim(app.IndicatorAxes, [0 100]);
            grid(app.IndicatorAxes, "on");
            try
                xlim(app.IndicatorAxes, [c.OpenTime(1) c.OpenTime(end)]);
            catch
            end
            legend(app.IndicatorAxes, {'Hist', 'MACD', 'Signal', 'RSI'}, "Location", "best");
            if preserveView
                app.applyChartLimits(c, false);
            else
                app.resetChartView();
            end
        end

        function renderAnalysis(app)
            if ~isempty(fieldnames(app.LatestAnalysisContext))
                lines = crypto.analysis.formatContextSnapshot(app.LatestAnalysisContext);
                lines = [lines; ""];
            else
                lines = strings(0, 1);
            end
            if ~isempty(fieldnames(app.LatestAgentRun))
                lines = [
                    lines;
                    "Agent Workbench";
                    string(app.LatestAgentRun.RunId);
                    "";
                    "Consensus";
                    string(app.LatestAgentRun.Consensus);
                    "";
                    "Disagreements";
                    string(app.LatestAgentRun.Disagreements);
                    "";
                    "Action Watchlist";
                    string(app.LatestAgentRun.ActionWatchlist);
                    ""
                    ];
            end
            if ~isempty(fieldnames(app.LatestAnalysisResult)) && isfield(app.LatestAnalysisResult, 'Text')
                lines = [lines; splitlines(string(app.LatestAnalysisResult.Text))];
            elseif ~isempty(app.LatestSummary) && isfield(app.LatestSummary, 'Text')
                lines = [lines; splitlines(string(app.LatestSummary.Text))];
            else
                lines = [lines; "AI 分析：等待行情数据。"];
            end
            app.renderEvidenceBlocks();
            if ~isempty(app.LatestPortfolio) && istable(app.LatestPortfolio)
                summary = crypto.portfolio.summarizePortfolio(app.LatestPortfolio);
                portfolioLines = [
                    "";
                    "Portfolio Intelligence";
                    "Total value: " + app.formatMoney(summary.TotalValue);
                    "Unrealized PnL: " + app.formatMoney(summary.TotalPnL) + " (" + sprintf("%.2f", summary.TotalPnLPercent) + "%)";
                    "Largest exposure: " + summary.LargestSymbol + " " + sprintf("%.1f", summary.LargestAllocation * 100) + "%";
                    "Cash / Invested: " + app.formatMoney(summary.CashValue) + " / " + app.formatMoney(summary.InvestedValue)
                    ];
                portfolioLines = [portfolioLines; crypto.portfolio.riskNarrative(summary)];
                lines = [lines; portfolioLines];
            end
            app.AnalysisTextArea.Value = app.textAreaValue(lines);
            app.renderAgentWorkbench();
            app.renderStrategyScoreTable();
            app.renderRiskContributionTable();
            app.renderStressResult();
        end

        function renderEvidenceBlocks(app)
            if isempty(fieldnames(app.LatestAnalysisContext))
                if ~isempty(app.HoldingImpactTextArea)
                    app.HoldingImpactTextArea.Value = app.textAreaValue("持仓影响：等待数据。");
                end
                if ~isempty(app.MarketLinkageTextArea)
                    app.MarketLinkageTextArea.Value = app.textAreaValue("市场联动：等待数据。");
                end
                return
            end
            app.HoldingImpactTextArea.Value = app.textAreaValue(crypto.analysis.formatHoldingImpact(app.LatestAnalysisContext));
            app.MarketLinkageTextArea.Value = app.textAreaValue(crypto.analysis.formatMarketLinkage(app.LatestAnalysisContext));
        end

        function renderAgentWorkbench(app)
            if isempty(app.AgentCardsTextArea) || isempty(app.IntegratedRecommendationTextArea)
                return
            end
            if isempty(fieldnames(app.LatestAgentRun))
                app.AgentCardsTextArea.Value = app.textAreaValue("Agent 集群输出：等待分析。");
                app.IntegratedRecommendationTextArea.Value = app.textAreaValue("综合建议：等待 Agent 集群完成分析。");
                return
            end
            app.AgentCardsTextArea.Value = app.textAreaValue(crypto.agents.formatCards(app.LatestAgentRun));
            app.IntegratedRecommendationTextArea.Value = app.textAreaValue(app.LatestAgentRun.IntegratedRecommendation);
        end

        function renderStrategyScoreTable(app)
            if isempty(app.StrategyScoreTable)
                return
            end
            if isempty(fieldnames(app.LatestAnalysisContext)) || ~isfield(app.LatestAnalysisContext, 'StrategyScores')
                app.StrategyScoreTable.Data = table();
                return
            end
            scores = app.LatestAnalysisContext.StrategyScores;
            if isempty(scores) || height(scores) == 0
                app.StrategyScoreTable.Data = table();
                return
            end
            displayScores = scores(:, {'Symbol', 'PriceActionScore', 'TrendScore', 'MeanReversionScore', 'CrossAssetScore', 'PortfolioImpactScore', 'ValuationScore', 'CompositeScore', 'CompositeView'});
            app.StrategyScoreTable.Data = displayScores;
        end

        function renderRiskContributionTable(app)
            if isempty(app.RiskContributionTable)
                return
            end
            if isempty(fieldnames(app.LatestAnalysisContext)) || ~isfield(app.LatestAnalysisContext, 'RiskContributions')
                app.RiskContributionTable.Data = table();
                return
            end
            risk = app.LatestAnalysisContext.RiskContributions;
            if isempty(risk) || height(risk) == 0
                app.RiskContributionTable.Data = table();
                return
            end
            displayRisk = risk(:, {'Symbol', 'AssetClass', 'Allocation', 'Volatility20', 'RiskScore', 'RiskContribution'});
            app.RiskContributionTable.Data = displayRisk;
        end

        function runStressScenario(app, scenarioName)
            if isempty(fieldnames(app.LatestAnalysisContext))
                return
            end
            switch string(scenarioName)
                case "crypto"
                    shock = struct("BTCUSDT", -0.05, "ETHUSDT", -0.06, "SOLUSDT", -0.08);
                    label = "加密资产回撤";
                case "tech"
                    shock = struct("SPY", -0.025, "QQQ", -0.04);
                    label = "科技股回撤";
                case "riskoff"
                    shock = struct("BTCUSDT", -0.06, "ETHUSDT", -0.07, "SOLUSDT", -0.10, "SPY", -0.03, "QQQ", -0.045);
                    label = "风险资产共振下跌";
                case "gold"
                    shock = struct("BTCUSDT", -0.03, "SPY", -0.02, "QQQ", -0.03, "GLD", 0.025);
                    label = "黄金避险上涨";
                otherwise
                    shock = struct();
                    label = "自定义冲击";
            end
            app.LatestStressResult = crypto.analysis.stressPortfolio(app.LatestAnalysisContext, shock);
            app.LatestStressResult.ScenarioName = label;
            app.renderStressResult();
        end

        function renderStressResult(app)
            if isempty(app.StressTextArea)
                return
            end
            if isempty(fieldnames(app.LatestStressResult))
                app.StressTextArea.Value = app.textAreaValue("压力测试：请选择情景。");
                return
            end
            stress = app.LatestStressResult;
            lines = [
                "压力测试：" + string(stress.ScenarioName);
                "组合冲击损益：" + app.formatMoney(stress.TotalShockPnL) + " (" + sprintf("%.2f", stress.TotalShockPnLPercent) + "%)"
                ];
            if isfield(stress, 'AssetImpact') && height(stress.AssetImpact) > 0
                worst = stress.AssetImpact(1, :);
                lines(end + 1, 1) = "最大损失来源：" + string(worst.Symbol) + " " + app.formatMoney(worst.ShockPnL);
            end
            app.StressTextArea.Value = app.textAreaValue(lines);
        end

        function renderEmptyAxes(~, ax, message)
            cla(ax);
            title(ax, "");
            label = text(ax, 0.5, 0.5, string(message), "HorizontalAlignment", "center");
            label.Units = "normalized";
            ax.XTick = [];
            ax.YTick = [];
        end

        function deleteCrossAssetCache(~, symbol)
            cacheFiles = [
                string(fullfile(pwd, "cache", "stooq", upper(char(string(symbol))) + ".csv"));
                string(fullfile(pwd, "cache", "fmp", upper(char(string(symbol))) + ".csv"));
                string(fullfile(pwd, "cache", "alpha_vantage", upper(char(string(symbol))) + ".csv"))
                ];
            for idx = 1:numel(cacheFiles)
                if isfile(cacheFiles(idx))
                    delete(cacheFiles(idx));
                end
            end
        end

        function applyAxesLimits(~, priceAxes, indicatorAxes, c, isDaily)
            if isempty(c) || height(c) == 0
                return
            end
            valid = ~isnan(c.Close) & ~isnan(c.High) & ~isnan(c.Low);
            if ~any(valid)
                return
            end

            firstIdx = find(valid, 1, "first");
            lastIdx = find(valid, 1, "last");
            xLimits = datenum([c.OpenTime(firstIdx) c.OpenTime(lastIdx)]);
            priceMin = min(c.Low(valid));
            priceMax = max(c.High(valid));
            padding = max((priceMax - priceMin) * (isDaily * 0.06 + ~isDaily * 0.03), eps(priceMax));
            xlim(priceAxes, xLimits);
            ylim(priceAxes, [priceMin - padding priceMax + padding]);
            try
                xlim(indicatorAxes, [c.OpenTime(firstIdx) c.OpenTime(lastIdx)]);
            catch
            end
        end

        function renderCrossAssetCharts(app, forceRefresh)
            if nargin < 2
                forceRefresh = false;
            end
            if isempty(app.CrossAssetDropDown) || strcmp(string(app.CrossAssetDropDown.Value), "NoData")
                app.renderEmptyAxes(app.CrossAssetPriceAxes, "No cross-asset source configured");
                cla(app.CrossAssetIndicatorAxes);
                return
            end

            symbol = string(app.CrossAssetDropDown.Value);
            try
                if forceRefresh
                    app.deleteCrossAssetCache(symbol);
                end
                candles = crypto.data.fetchCandles(symbol, "1d", 120);
                enriched = crypto.indicators.enrichCandles(candles);
                app.renderDailyAssetAxes(symbol, enriched);
            catch err
                app.renderEmptyAxes(app.CrossAssetPriceAxes, "Unable to load " + symbol);
                cla(app.CrossAssetIndicatorAxes);
                title(app.CrossAssetIndicatorAxes, "Cross-Asset MACD / RSI");
                app.StatusLabel.Text = "Cross-asset skipped: " + string(err.message);
            end
        end

        function renderDailyAssetAxes(app, symbol, c)
            if isempty(c) || height(c) == 0
                app.renderEmptyAxes(app.CrossAssetPriceAxes, "No daily data for " + symbol);
                return
            end

            cla(app.CrossAssetPriceAxes);
            reset(app.CrossAssetPriceAxes);
            app.configureAxesInteraction(app.CrossAssetPriceAxes);
            validClose = ~isnan(c.Close) & ~isnan(c.Open) & ~isnan(c.High) & ~isnan(c.Low);
            app.drawCandles(app.CrossAssetPriceAxes, c(validClose, :));
            hold(app.CrossAssetPriceAxes, "on");
            validMa = ~isnan(c.MA20);
            if any(validMa)
                plot(app.CrossAssetPriceAxes, datenum(c.OpenTime(validMa)), c.MA20(validMa), "Color", [0.95 0.65 0.1], "LineWidth", 1.2);
            end
            hold(app.CrossAssetPriceAxes, "off");
            grid(app.CrossAssetPriceAxes, "on");
            title(app.CrossAssetPriceAxes, symbol + " Daily / MA20");
            xlabel(app.CrossAssetPriceAxes, "Date");
            ylabel(app.CrossAssetPriceAxes, "Price");

            cla(app.CrossAssetIndicatorAxes);
            reset(app.CrossAssetIndicatorAxes);
            app.configureAxesInteraction(app.CrossAssetIndicatorAxes);
            yyaxis(app.CrossAssetIndicatorAxes, "left");
            bar(app.CrossAssetIndicatorAxes, c.OpenTime, c.MACDHistogram, "FaceColor", [0.45 0.55 0.7], "EdgeColor", "none");
            hold(app.CrossAssetIndicatorAxes, "on");
            plot(app.CrossAssetIndicatorAxes, c.OpenTime, c.MACD, "Color", [0.1 0.35 0.75], "LineWidth", 1.1);
            plot(app.CrossAssetIndicatorAxes, c.OpenTime, c.MACDSignal, "Color", [0.85 0.25 0.1], "LineWidth", 1.1);
            hold(app.CrossAssetIndicatorAxes, "off");
            ylabel(app.CrossAssetIndicatorAxes, "MACD");
            yyaxis(app.CrossAssetIndicatorAxes, "right");
            plot(app.CrossAssetIndicatorAxes, c.OpenTime, c.RSI14, "LineWidth", 1.2);
            yline(app.CrossAssetIndicatorAxes, 70, "--");
            yline(app.CrossAssetIndicatorAxes, 30, "--");
            ylabel(app.CrossAssetIndicatorAxes, "RSI");
            ylim(app.CrossAssetIndicatorAxes, [0 100]);
            grid(app.CrossAssetIndicatorAxes, "on");
            legend(app.CrossAssetIndicatorAxes, {'Hist', 'MACD', 'Signal', 'RSI'}, "Location", "best");
            app.applyAxesLimits(app.CrossAssetPriceAxes, app.CrossAssetIndicatorAxes, c, true);
        end

        function candles = visibleCandles(app)
            allCandles = app.LatestCandles;
            if isempty(allCandles) || height(allCandles) == 0
                candles = allCandles;
                return
            end

            windowSize = min(app.VisibleCandleCount, height(allCandles));
            maxStart = max(1, height(allCandles) - windowSize + 1);
            app.WindowStartIndex = min(max(1, round(app.WindowStartIndex)), maxStart);
            lastIdx = min(height(allCandles), app.WindowStartIndex + windowSize - 1);
            candles = allCandles(app.WindowStartIndex:lastIdx, :);
        end

        function updateChartNavigationControls(app, previousStart, previousWasLatest)
            if isempty(app.LatestCandles) || height(app.LatestCandles) == 0
                app.HistorySlider.Limits = [1 1.0001];
                app.HistorySlider.Value = 1;
                app.HistorySlider.Enable = "off";
                app.WindowStartIndex = 1;
                app.FollowLatest = true;
                return
            end

            app.VisibleCandleCount = str2double(app.VisibleCandlesDropDown.Value);
            windowSize = min(app.VisibleCandleCount, height(app.LatestCandles));
            maxStart = max(1, height(app.LatestCandles) - windowSize + 1);

            if previousWasLatest
                app.WindowStartIndex = maxStart;
                app.FollowLatest = true;
            else
                app.WindowStartIndex = min(max(1, round(previousStart)), maxStart);
                app.FollowLatest = false;
            end

            if maxStart == 1
                app.HistorySlider.Limits = [1 1.0001];
                app.HistorySlider.Value = 1;
                app.HistorySlider.Enable = "off";
            else
                app.HistorySlider.Enable = "on";
                app.HistorySlider.Limits = [1 maxStart];
                app.HistorySlider.Value = app.WindowStartIndex;
                try
                    app.HistorySlider.MajorTicks = unique(round(linspace(1, maxStart, min(5, maxStart))));
                catch
                end
            end
            app.setVisibleWindowControlValue(windowSize);
        end

        function onVisibleWindowChanged(app)
            app.VisibleCandleCount = str2double(app.VisibleCandlesDropDown.Value);
            app.updateChartNavigationControls(app.WindowStartIndex, app.FollowLatest);
            app.renderCharts();
        end

        function onHistorySliderChanged(app)
            app.WindowStartIndex = round(app.HistorySlider.Value);
            app.FollowLatest = false;
            app.renderCharts();
        end

        function onHistorySliderChanging(app, event)
            app.WindowStartIndex = round(event.Value);
            app.FollowLatest = false;
            app.renderCharts();
        end

        function setLatestView(app)
            app.FollowLatest = true;
            app.updateChartNavigationControls(app.WindowStartIndex, true);
            app.renderCharts();
        end

        function updatePortfolio(app)
            if isempty(app.LatestTickers)
                return
            end

            holdings = app.normalizedPortfolioPositions();
            prices = crypto.portfolio.priceTableWithCash(app.LatestTickers);
            result = crypto.portfolio.calculateHoldings(holdings, prices);
            app.LatestPortfolio = result;
            app.PortfolioTable.Data = result(:, {'Symbol', 'AssetClass', 'Quantity', 'LastPrice', 'MarketValue', 'UnrealizedPnL', 'UnrealizedPnLPercent', 'Allocation'});
            app.renderPortfolioAllocation(result);
            app.renderPortfolioSummary(result);
        end

        function updateAiAnalysis(app, useDeepSeek)
            if nargin < 2
                useDeepSeek = false;
            end
            try
                if isempty(app.LatestTickers) || isempty(app.LatestPortfolio)
                    return
                end
                app.LatestAnalysisCandles = app.loadAnalysisCandles();
                app.LatestAnalysisContext = crypto.analysis.buildContext(app.LatestTickers, app.LatestAnalysisCandles, app.LatestPortfolio);
                app.LatestAnalysisContext = app.attachStressToContext(app.LatestAnalysisContext);
                app.LatestAgentRun = crypto.agents.runResearchAgents(app.LatestAnalysisContext);
                app.LatestAnalysisResult = crypto.analysis.analyzeContext(app.LatestAnalysisContext);
                if useDeepSeek
                    deepSeekResult = crypto.analysis.deepSeekAnalyzeContext(app.LatestAnalysisContext);
                    if deepSeekResult.Provider == "deepseek"
                        app.LatestAnalysisResult = deepSeekResult;
                    else
                        app.LatestAnalysisResult.Text = deepSeekResult.Text + newline + newline + app.LatestAnalysisResult.Text;
                        app.LatestAnalysisResult.LLMAdapter = deepSeekResult.LLMAdapter;
                    end
                end
            catch err
                app.LatestAnalysisResult = struct("Provider", "local-rules", ...
                    "Text", "AI 分析不可用：" + string(err.message), ...
                    "Highlights", strings(0, 1), ...
                    "LLMAdapter", struct("Status", "reserved", "ExpectedInput", "context.LLMPayload"));
            end
        end

        function context = attachStressToContext(app, context)
            if ~isempty(fieldnames(app.LatestStressResult))
                context.StressResult = app.LatestStressResult;
                context.LLMPayload.stressResult = app.LatestStressResult;
            end
        end

        function runDeepSeekAnalysis(app)
            previousStatus = app.StatusLabel.Text;
            try
                app.AnalyzeAiButton.Enable = "off";
                app.StatusLabel.Text = "正在调用 DeepSeek AI...";
                drawnow;
                app.updateAiAnalysis(true);
                app.renderAnalysis();
                if isfield(app.LatestAnalysisResult, 'Provider') && app.LatestAnalysisResult.Provider == "deepseek"
                    app.StatusLabel.Text = "DeepSeek 分析已更新";
                else
                    app.StatusLabel.Text = "DeepSeek 回退：" + string(app.LatestAnalysisResult.LLMAdapter.Status);
                end
            catch err
                app.StatusLabel.Text = "AI 错误：" + string(err.message);
            end
            app.AnalyzeAiButton.Enable = "on";
            if strlength(app.StatusLabel.Text) == 0
                app.StatusLabel.Text = previousStatus;
            end
        end

        function candlesBySymbol = loadAnalysisCandles(app)
            symbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "SPY", "QQQ", "GLD"];
            candlesBySymbol = struct();
            for idx = 1:numel(symbols)
                symbol = symbols(idx);
                try
                    if symbol == string(app.AssetDropDown.Value) && string(app.IntervalDropDown.Value) == "1d" && ~isempty(app.LatestCandles)
                        candles = app.LatestCandles;
                    else
                        candles = crypto.data.fetchCandles(symbol, "1d", 120);
                        candles = crypto.indicators.enrichCandles(candles);
                    end
                    field = matlab.lang.makeValidName(char(symbol));
                    candlesBySymbol.(field) = candles;
                catch
                    % Keep AI analysis available with the assets that loaded.
                end
            end
        end

        function onPortfolioInputEdited(app, src)
            app.PortfolioPositions = src.Data;
            app.updatePortfolio();
            app.updateAiAnalysis(false);
            app.renderAnalysis();
        end

        function onHoldingCellSelected(app, event)
            try
                if ~isempty(event.Indices)
                    app.SelectedHoldingRow = event.Indices(1, 1);
                end
            catch
                app.SelectedHoldingRow = NaN;
            end
        end

        function addHoldingRow(app)
            answer = inputdlg({"输入资产代码，例如 BTCUSDT、SPY、QQQ、GLD、USDT"}, "新增持仓", [1 52], {""});
            if isempty(answer)
                return
            end
            symbol = upper(strtrim(string(answer{1})));
            if strlength(symbol) == 0
                return
            end
            assetClass = app.assetClassForSymbol(symbol);
            app.PortfolioPositions = crypto.portfolio.appendPosition(app.normalizedPortfolioPositions(), symbol, assetClass);
            app.HoldingsInputTable.Data = app.PortfolioPositions;
            app.updatePortfolio();
            app.updateAiAnalysis(false);
            app.renderAnalysis();
        end

        function removeHoldingRow(app)
            positions = app.normalizedPortfolioPositions();
            if isempty(positions) || height(positions) == 0
                return
            end
            row = app.SelectedHoldingRow;
            if isnan(row) || row < 1 || row > height(positions)
                row = height(positions);
            end
            symbol = string(positions.Symbol(row));
            app.PortfolioPositions = crypto.portfolio.removePosition(positions, symbol);
            app.SelectedHoldingRow = NaN;
            app.HoldingsInputTable.Data = app.PortfolioPositions;
            app.updatePortfolio();
            app.updateAiAnalysis(false);
            app.renderAnalysis();
        end

        function assetClass = assetClassForSymbol(~, symbol)
            try
                assets = crypto.assets.universe();
                row = find(strcmp(string(assets.Symbol), symbol), 1, "first");
                if ~isempty(row)
                    assetClass = string(assets.AssetClass(row));
                    return
                end
            catch
            end
            assetClass = "Unknown";
        end

        function positions = normalizedPortfolioPositions(app)
            positions = app.PortfolioPositions;
            requiredNames = ["Symbol", "AssetClass", "Quantity", "CostBasis"];
            if isempty(positions) || ~istable(positions) || ~all(ismember(requiredNames, string(positions.Properties.VariableNames)))
                positions = crypto.portfolio.defaultPositions();
            end
            positions.Symbol = string(positions.Symbol);
            positions.AssetClass = string(positions.AssetClass);
            positions.Quantity = double(positions.Quantity);
            positions.CostBasis = double(positions.CostBasis);
            positions.Quantity(isnan(positions.Quantity)) = 0;
            positions.CostBasis(isnan(positions.CostBasis)) = 0;
            app.PortfolioPositions = positions(:, requiredNames);
            app.HoldingsInputTable.Data = app.PortfolioPositions;
        end

        function renderPortfolioAllocation(app, result)
            cla(app.AllocationAxes);
            if isempty(result) || height(result) == 0 || sum(result.MarketValue, "omitnan") <= 0
                title(app.AllocationAxes, "Asset Allocation");
                text(app.AllocationAxes, 0.5, 0.5, "No positions", "HorizontalAlignment", "center");
                app.AllocationAxes.XTick = [];
                app.AllocationAxes.YTick = [];
                return
            end

            valid = result.MarketValue > 0 & ~isnan(result.MarketValue);
            labels = erase(string(result.Symbol(valid)), "USDT");
            values = result.MarketValue(valid);
            pie(app.AllocationAxes, values, labels);
            title(app.AllocationAxes, "Asset Allocation");
        end

        function renderPortfolioSummary(app, result)
            summary = crypto.portfolio.summarizePortfolio(result);
            app.PortfolioSummaryLabel.Text = "Total " + app.formatMoney(summary.TotalValue) + ...
                " | PnL " + app.formatMoney(summary.TotalPnL) + ...
                " | Max " + summary.LargestSymbol + " " + sprintf("%.1f", summary.LargestAllocation * 100) + "%";
        end

        function exportCurrentData(app)
            if isempty(app.LatestTickers) || isempty(app.LatestCandles)
                return
            end

            outputDir = fullfile(pwd, "exports", datestr(now, "yyyymmdd_HHMMSS"));
            crypto.export.writeTable(app.LatestTickers, fullfile(outputDir, "tickers.csv"));
            crypto.export.writeTable(app.LatestCandles, fullfile(outputDir, "candles.csv"));
            if ~isempty(app.LatestPortfolio) && istable(app.LatestPortfolio)
                crypto.export.writeTable(app.LatestPortfolio, fullfile(outputDir, "portfolio.csv"));
            end
            crypto.portfolio.writePositions(app.normalizedPortfolioPositions(), fullfile(outputDir, "portfolio_positions_input.csv"));
            crypto.export.writeTable(crypto.assets.universe(), fullfile(outputDir, "asset_universe.csv"));
            crypto.export.writeSummary(app.LatestSummary, fullfile(outputDir, "analysis.txt"));
            app.StatusLabel.Text = "Exported to " + string(outputDir);
        end

        function importHoldings(app)
            [fileName, folder] = uigetfile({'*.csv;*.xlsx;*.xls', 'Portfolio files (*.csv, *.xlsx, *.xls)'}, "导入持仓");
            if isequal(fileName, 0)
                return
            end
            try
                app.PortfolioPositions = crypto.portfolio.readPositions(fullfile(folder, fileName));
                app.HoldingsInputTable.Data = app.PortfolioPositions;
                app.updatePortfolio();
                app.updateAiAnalysis(false);
                app.renderAnalysis();
                app.StatusLabel.Text = "持仓已导入";
            catch err
                app.StatusLabel.Text = "导入持仓失败：" + string(err.message);
            end
        end

        function exportHoldings(app)
            [fileName, folder] = uiputfile({'*.csv', 'CSV file (*.csv)'; '*.xlsx', 'Excel file (*.xlsx)'}, "导出持仓", "portfolio_positions.csv");
            if isequal(fileName, 0)
                return
            end
            try
                positions = app.normalizedPortfolioPositions();
                crypto.portfolio.writePositions(positions, fullfile(folder, fileName));
                app.StatusLabel.Text = "持仓已导出";
            catch err
                app.StatusLabel.Text = "导出持仓失败：" + string(err.message);
            end
        end

        function drawCandles(~, ax, candles)
            if height(candles) == 0
                return
            end

            times = datenum(candles.OpenTime);
            upColor = [0.1 0.62 0.35];
            downColor = [0.82 0.18 0.18];
            if height(candles) > 1
                stepDays = median(diff(times));
                halfWidth = max(stepDays * 0.32, 1 / (24 * 60 * 8));
            else
                halfWidth = 1 / 48;
            end

            hold(ax, "on");
            for idx = 1:height(candles)
                if candles.Close(idx) >= candles.Open(idx)
                    color = upColor;
                else
                    color = downColor;
                end
                wick = plot(ax, [times(idx) times(idx)], [candles.Low(idx) candles.High(idx)], "Color", color, "LineWidth", 1);
                wick.Annotation.LegendInformation.IconDisplayStyle = "off";
                left = times(idx) - halfWidth;
                right = times(idx) + halfWidth;
                bottom = min(candles.Open(idx), candles.Close(idx));
                top = max(candles.Open(idx), candles.Close(idx));
                if top == bottom
                    top = top + eps(top);
                end
                body = patch(ax, [left right right left], [bottom bottom top top], color, "EdgeColor", color, "FaceAlpha", 0.8);
                body.Annotation.LegendInformation.IconDisplayStyle = "off";
            end
            datetick(ax, "x", "keeplimits");
            hold(ax, "off");
        end

        function resetChartView(app)
            c = app.visibleCandles();
            app.applyChartLimits(c, true);
        end

        function applyChartLimits(app, c, addPadding)
            if isempty(c) || height(c) == 0
                return
            end

            valid = ~isnan(c.Close) & ~isnan(c.High) & ~isnan(c.Low);
            if ~any(valid)
                return
            end

            firstIdx = find(valid, 1, "first");
            lastIdx = find(valid, 1, "last");
            xLimits = datenum([c.OpenTime(firstIdx) c.OpenTime(lastIdx)]);
            priceMin = min(c.Low(valid));
            priceMax = max(c.High(valid));
            if addPadding
                padding = max((priceMax - priceMin) * 0.08, eps(priceMax));
            else
                padding = max((priceMax - priceMin) * 0.03, eps(priceMax));
            end
            xlim(app.PriceAxes, xLimits);
            ylim(app.PriceAxes, [priceMin - padding priceMax + padding]);
            try
                xlim(app.IndicatorAxes, [c.OpenTime(firstIdx) c.OpenTime(lastIdx)]);
            catch
            end
        end

        function onChartScroll(app, event)
            if isempty(app.LatestCandles) || height(app.LatestCandles) == 0
                return
            end

            totalCandles = height(app.LatestCandles);
            [startIndex, windowSize] = crypto.chart.zoomWindow(totalCandles, app.WindowStartIndex, app.VisibleCandleCount, event.VerticalScrollCount, 0.5);
            app.WindowStartIndex = startIndex;
            app.VisibleCandleCount = windowSize;
            app.FollowLatest = app.WindowStartIndex >= max(1, totalCandles - windowSize + 1);
            app.setVisibleWindowControlValue(windowSize);
            app.updateChartNavigationControls(app.WindowStartIndex, app.FollowLatest);
            app.renderCharts();
        end

        function onChartMouseDown(app)
            if isempty(app.LatestCandles) || height(app.LatestCandles) == 0
                return
            end
            if ~strcmp(string(app.Figure.SelectionType), "normal")
                return
            end
            if ~app.isPointerOverAxes(app.PriceAxes)
                return
            end
            app.IsChartDragging = true;
            point = app.PriceAxes.CurrentPoint;
            app.DragStartX = point(1, 1);
            app.DragStartWindowStart = app.WindowStartIndex;
        end

        function onChartMouseMove(app)
            if ~app.IsChartDragging || isempty(app.LatestCandles) || height(app.LatestCandles) == 0
                return
            end

            point = app.PriceAxes.CurrentPoint;
            currentX = point(1, 1);
            dataDelta = currentX - app.DragStartX;
            totalCandles = height(app.LatestCandles);
            stepDays = app.currentCandleStepDays();
            deltaCandles = -dataDelta / stepDays;
            [startIndex, windowSize] = crypto.chart.panWindow(totalCandles, app.DragStartWindowStart, app.VisibleCandleCount, deltaCandles);
            app.WindowStartIndex = startIndex;
            app.VisibleCandleCount = windowSize;
            app.FollowLatest = app.WindowStartIndex >= max(1, totalCandles - windowSize + 1);
            app.setVisibleWindowControlValue(windowSize);
            app.renderCharts();
        end

        function onChartMouseUp(app)
            app.IsChartDragging = false;
            app.DragStartX = NaN;
        end

        function setVisibleWindowControlValue(app, windowSize)
            value = num2str(windowSize);
            items = cellstr(app.VisibleCandlesDropDown.Items);
            if ~any(strcmp(items, value))
                numericItems = str2double([items, {value}]);
                numericItems = unique(numericItems(~isnan(numericItems)));
                items = cellstr(string(numericItems));
                app.VisibleCandlesDropDown.Items = reshape(items, 1, []);
            end
            app.VisibleCandlesDropDown.Value = value;
            app.VisibleCandleCount = windowSize;
        end

        function isInside = isPointerOverAxes(app, ax)
            isInside = false;
            try
                point = ax.CurrentPoint;
                xLimits = xlim(ax);
                yLimits = ylim(ax);
                x = point(1, 1);
                y = point(1, 2);
                isInside = x >= xLimits(1) && x <= xLimits(2) && y >= yLimits(1) && y <= yLimits(2);
            catch
            end
        end

        function stepDays = currentCandleStepDays(app)
            c = app.visibleCandles();
            if height(c) > 1
                stepDays = median(diff(datenum(c.OpenTime)));
            else
                stepDays = 1 / 24;
            end
            if isnan(stepDays) || stepDays <= 0
                stepDays = 1 / 24;
            end
        end

        function value = formatMoney(~, amount)
            if isnan(amount)
                amount = 0;
            end
            value = "$" + string(sprintf("%.2f", amount));
        end

        function configureAxesInteraction(~, ax)
            try
                disableDefaultInteractivity(ax);
            catch
            end
            try
                ax.Interactions = [zoomInteraction dataTipInteraction];
            catch
            end
            try
                ax.Toolbar.Visible = "off";
            catch
            end
        end

        function toggleAutoRefresh(app)
            if app.AutoRefreshCheckBox.Value
                app.startAutoRefresh();
            else
                app.stopAutoRefresh();
            end
        end

        function restartAutoRefresh(app)
            if app.AutoRefreshCheckBox.Value
                app.stopAutoRefresh();
                app.startAutoRefresh();
            end
        end

        function startAutoRefresh(app)
            seconds = str2double(app.RefreshSecondsDropDown.Value);
            app.RefreshTimer = timer( ...
                "ExecutionMode", "fixedSpacing", ...
                "Period", seconds, ...
                "BusyMode", "drop", ...
                "TimerFcn", @(~,~) app.refreshData(false));
            start(app.RefreshTimer);
            app.StatusLabel.Text = "Auto refresh on";
        end

        function stopAutoRefresh(app)
            if ~isempty(app.RefreshTimer) && isvalid(app.RefreshTimer)
                stop(app.RefreshTimer);
                delete(app.RefreshTimer);
            end
            app.RefreshTimer = [];
        end

        function finishRefresh(app)
            app.IsRefreshing = false;
        end

        function closeApp(app)
            app.stopAutoRefresh();
            delete(app.Figure);
        end

        function value = textAreaValue(~, value)
            value = cellstr(string(value));
            value = reshape(value, [], 1);
        end
    end
end
