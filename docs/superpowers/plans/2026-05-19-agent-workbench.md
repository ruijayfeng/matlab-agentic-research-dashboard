# Agent Workbench Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a visible MATLAB-native Agent cluster workbench to the existing multi-asset dashboard.

**Architecture:** Keep MATLAB as the runtime and computation engine. Add a focused `+crypto/+agents` package that wraps the existing analysis context into deterministic Agent results, then render the orchestrated research run in the existing app's AI tab.

**Tech Stack:** MATLAB package functions, `struct`, `table`, `matlab.unittest`, `uifigure`/`uitable`/`uitextarea`.

---

### Task 1: Agent Contract Tests

**Files:**
- Create: `tests/TestAgents.m`
- Read: `tests/TestAnalysis.m`

- [ ] Create deterministic test fixtures for tickers, candles, portfolio, and context.
- [ ] Add a test that `crypto.agents.runResearchAgents(context)` returns five Agent results.
- [ ] Add assertions for required fields: `Name`, `Role`, `Status`, `Confidence`, `Headline`, `Evidence`, `Risks`, `Recommendation`, `Timestamp`.
- [ ] Run `matlab -batch "runtests('tests/TestAgents.m')"` and confirm it fails because `crypto.agents.runResearchAgents` does not exist.

### Task 2: Core Agent Package

**Files:**
- Create: `+crypto/+agents/requiredFields.m`
- Create: `+crypto/+agents/makeResult.m`
- Create: `+crypto/+agents/runResearchAgents.m`
- Create: `+crypto/+agents/dataQualityAgent.m`
- Create: `+crypto/+agents/technicalAgent.m`
- Create: `+crypto/+agents/portfolioRiskAgent.m`
- Create: `+crypto/+agents/macroLinkageAgent.m`
- Create: `+crypto/+agents/criticAgent.m`
- Create: `+crypto/+agents/buildConsensus.m`

- [ ] Implement the minimal deterministic Agent result contract.
- [ ] Implement five Agents over the existing analysis context.
- [ ] Implement consensus, disagreement, action watchlist, and evidence log aggregation.
- [ ] Run `matlab -batch "runtests('tests/TestAgents.m')"` and confirm Agent tests pass.

### Task 3: Agent Edge Case Tests

**Files:**
- Modify: `tests/TestAgents.m`

- [ ] Add a test that `dataQualityAgent` returns `warning` when required context sections are missing.
- [ ] Add a test that `criticAgent` flags conflict when technical output is bullish and portfolio risk output reports concentration.
- [ ] Add a test that consensus includes watchlist and evidence log lines.
- [ ] Run `matlab -batch "runtests('tests/TestAgents.m')"` and confirm tests fail before implementation updates if needed.
- [ ] Update Agent implementations until the focused tests pass.

### Task 4: Dashboard Integration

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`

- [ ] Add app property `LatestAgentRun`.
- [ ] Change the AI tab title to `Agent Workbench`.
- [ ] Add flow, Agent table, consensus, disagreement, action watchlist, and evidence log controls.
- [ ] In `updateAiAnalysis`, call `crypto.agents.runResearchAgents` after building context.
- [ ] Render Agent outputs in the new controls.
- [ ] Preserve existing DeepSeek/local report text area.

### Task 5: Verification

**Files:**
- Test: `tests/TestAgents.m`
- Test: `tests`
- Run: `diagnoseCryptoDashboard.m`

- [ ] Run `matlab -batch "runtests('tests/TestAgents.m')"`.
- [ ] Run `matlab -batch "runtests('tests')"`.
- [ ] Run `matlab -batch "diagnoseCryptoDashboard"`.
- [ ] Confirm Git diff contains only intended spec, plan, Agent package, tests, and app integration changes.
