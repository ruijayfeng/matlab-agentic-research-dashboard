# Crypto Asset Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a MATLAB dashboard for BTC, ETH, and SOL market monitoring, technical analysis, AI-style insights, portfolio tracking, and export.

**Architecture:** Public Binance data is normalized into tables, MATLAB package functions calculate indicators and portfolio metrics, and a programmatic App Designer-style class renders the dashboard. AI behavior is deterministic in v1: MATLAB produces facts and rule-based insight text that can later be sent to an LLM.

**Tech Stack:** MATLAB tables/timetables, `webread`, `uifigure`, `uiaxes`, `uitable`, `matlab.unittest`, Binance public REST API.

---

### Task 1: Core Tests

**Files:**
- Create: `tests/TestIndicators.m`
- Create: `tests/TestPortfolio.m`
- Create: `tests/TestAnalysis.m`

- [ ] Write tests for MA, MACD, RSI, portfolio value/PnL/allocation, and deterministic analysis labels.
- [ ] Run `matlab -batch "runtests('tests')"` and confirm tests fail because functions do not exist.

### Task 2: Core Calculation Packages

**Files:**
- Create: `+crypto/+indicators/movingAverage.m`
- Create: `+crypto/+indicators/macd.m`
- Create: `+crypto/+indicators/rsi.m`
- Create: `+crypto/+indicators/enrichCandles.m`
- Create: `+crypto/+portfolio/calculateHoldings.m`
- Create: `+crypto/+analysis/summarizeMarket.m`

- [ ] Implement the minimum package functions needed by the tests.
- [ ] Run `matlab -batch "runtests('tests')"` and confirm the tests pass.

### Task 3: Binance Data Layer

**Files:**
- Create: `+crypto/+data/defaultSymbols.m`
- Create: `+crypto/+data/fetch24hTickers.m`
- Create: `+crypto/+data/fetchKlines.m`

- [ ] Add Binance ticker and K-line fetchers for BTCUSDT, ETHUSDT, and SOLUSDT.
- [ ] Add typed table normalization and clear error messages.
- [ ] Verify a live BTC ticker and BTC 1h K-line request from PowerShell.

### Task 4: Export Layer

**Files:**
- Create: `+crypto/+export/writeTable.m`
- Create: `+crypto/+export/writeSummary.m`

- [ ] Add CSV/XLSX table export.
- [ ] Add text summary export.
- [ ] Add or update tests for export path validation if MATLAB is available.

### Task 5: Dashboard App

**Files:**
- Create: `app/CryptoAssetDashboardApp.m`
- Create: `runCryptoDashboard.m`

- [ ] Build a programmatic `uifigure` dashboard with asset selector, timeframe selector, refresh button, export button, market table, K-line axes, indicator axes, AI analysis text area, and portfolio table.
- [ ] Wire refresh to the data and indicator layers.
- [ ] Wire export to the export layer.

### Task 6: Verification

**Files:**
- Read: all created MATLAB files

- [ ] Run MATLAB unit tests if MATLAB is available.
- [ ] Run PowerShell live API checks for Binance ticker and K-lines.
- [ ] Report any unrun MATLAB verification clearly.

