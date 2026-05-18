# AI Analysis Context Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first AI Analysis framework around structured multi-asset context, local rule-based analysis, and an LLM-ready payload.

**Architecture:** Add focused functions under `+crypto/+analysis` for context creation and local analysis. Keep UI integration narrow by rendering the new analysis in the existing text area and preserving the current quote/chart layout.

**Tech Stack:** MATLAB package functions, `table`, `struct`, matrix covariance/correlation calculations, `matlab.unittest`.

---

### Task 1: Analysis Context

**Files:**
- Create: `+crypto/+analysis/buildContext.m`
- Modify: `tests/TestAnalysis.m`

- [ ] Write a failing unit test that creates deterministic candles for BTCUSDT, ETHUSDT, SOLUSDT, SPY, QQQ, and GLD, then verifies `buildContext` returns `MarketSnapshot`, `TechnicalState`, `Correlation`, `RiskContributions`, `Signals`, and `LLMPayload`.
- [ ] Run `runtests("tests/TestAnalysis.m")` and verify the test fails because `crypto.analysis.buildContext` is undefined.
- [ ] Implement `buildContext` with small helper functions for table extraction, returns alignment, correlation, risk contribution, and LLM payload creation.
- [ ] Run `runtests("tests/TestAnalysis.m")` and verify the new and existing analysis tests pass.

### Task 2: Local Rule AI Analyzer

**Files:**
- Create: `+crypto/+analysis/analyzeContext.m`
- Modify: `tests/TestAnalysis.m`

- [ ] Write a failing unit test that feeds a context with concentrated BTC allocation and elevated crypto risk, then verifies `analyzeContext` returns provider `local-rules`, readable text, and highlights.
- [ ] Run `runtests("tests/TestAnalysis.m")` and verify the test fails because `crypto.analysis.analyzeContext` is undefined.
- [ ] Implement `analyzeContext` using deterministic rules over concentration, crypto risk contribution, strongest/weakest relative strength, correlation regime, volatility spikes, and gold hedge behavior.
- [ ] Run `runtests("tests/TestAnalysis.m")` and verify all analysis tests pass.

### Task 3: Dashboard Integration

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`

- [ ] Add app properties for `LatestAnalysisContext`, `LatestAnalysisResult`, and `LatestAnalysisCandles`.
- [ ] Add a private method that loads daily analysis candles for BTCUSDT, ETHUSDT, SOLUSDT, SPY, QQQ, and GLD, reusing currently loaded candles when possible and catching unavailable data per symbol.
- [ ] After portfolio refresh, build the analysis context and render local-rule AI text in `renderAnalysis`.
- [ ] Keep existing market table, chart tabs, and portfolio controls unchanged.

### Task 4: Verification

**Files:**
- Test: `tests/TestAnalysis.m`
- Test: `tests/TestPortfolio.m`

- [ ] Run `runtests("tests")`.
- [ ] Run `diagnoseCryptoDashboard`.
- [ ] Record any skipped verification caused by local MATLAB/toolbox availability.
