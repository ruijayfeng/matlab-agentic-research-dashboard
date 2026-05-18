# AI Workbench Next Steps Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the dashboard into a real AI analysis workbench with obvious portfolio input, clearer risk linkage, and readable Chinese analysis output.

**Architecture:** Keep MATLAB as the computation engine and DeepSeek as the explanation layer. Strengthen the holdings input path first so portfolio data reliably feeds risk contribution, then expand the AI tab into distinct evidence/report blocks, and finally add import/export and scenario analysis.

**Tech Stack:** MATLAB `uifigure`/`uitable`, package functions under `+crypto`, `matlab.unittest`, JSON config for local API keys.

---

### Task 1: Make Portfolio Entry Obvious

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`
- Modify: `tests/TestPortfolio.m`

- [x] Add explicit UI text explaining that users edit `Qty` and `Cost` to enter holdings.
- [x] Add add-row and remove-row controls for portfolio positions.
- [x] Add a test that verifies a new holding row can be appended and normalized into `PortfolioPositions`.
- [x] Run `runtests("tests/TestPortfolio.m")` and verify the new test passes.

### Task 2: Distinguish Evidence From Report

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`
- Modify: `tests/TestAnalysis.m`
- Create: `+crypto/+analysis/formatHoldingImpact.m`
- Create: `+crypto/+analysis/formatMarketLinkage.m`

- [x] Write tests for two new formatter functions that produce Chinese evidence blocks from `context`.
- [x] Implement the formatters so the AI tab shows holdings impact, market linkage, and the DeepSeek report as separate sections.
- [x] Run `runtests("tests/TestAnalysis.m")` and verify all analysis tests pass.

### Task 3: Add Import / Export Path for Holdings

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`
- Modify: `+crypto/+export/writeTable.m`
- Create: `+crypto/+export/readTable.m`

- [x] Add CSV import for holdings so the user can load a portfolio file instead of typing every row.
- [x] Extend export so holdings can be saved and reloaded cleanly.
- [x] Add tests covering round-trip export/import for portfolio rows.

### Task 4: Add Scenario Analysis

**Files:**
- Create: `+crypto/+analysis/stressPortfolio.m`
- Modify: `tests/TestAnalysis.m`

- [x] Write a failing test for a simple price shock scenario.
- [x] Implement portfolio shock projection using current holdings and prices.
- [x] Show the shock impact inside the AI workbench.

### Task 5: Verification

**Files:**
- Test: `tests/TestAnalysis.m`
- Test: `tests/TestPortfolio.m`

- [x] Run `runtests("tests")`.
- [x] Run `runCryptoDashboard` and verify the portfolio input flow is obvious.
- [x] Run `diagnoseCryptoDashboard` and confirm the AI report still renders in Chinese.
