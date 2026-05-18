# Native Chart Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add native MATLAB chart navigation controls for visible candle count, history scrolling, latest-follow behavior, and auto refresh preservation.

**Architecture:** Keep the existing programmatic UI class and add chart state fields plus helper methods. Rendering slices `LatestCandles` into a visible subset before drawing price and indicator axes.

**Tech Stack:** MATLAB `uifigure`, `uiaxes`, `uislider`, `uidropdown`, Binance REST data already implemented.

---

### Task 1: Add Chart State and Controls

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`

- [ ] Add properties for visible candle count, window start index, follow-latest flag, slider, dropdown, and latest button.
- [ ] Add controls to the top toolbar.

### Task 2: Windowed Rendering

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`

- [ ] Add `visibleCandles`, `updateChartNavigationControls`, `setLatestView`, and `onHistorySliderChanged` helpers.
- [ ] Change `renderCharts` to draw only visible candles.

### Task 3: Refresh Behavior

**Files:**
- Modify: `app/CryptoAssetDashboardApp.m`

- [ ] Fetch a larger candle limit.
- [ ] Preserve history view when auto refresh updates data.
- [ ] Keep latest-follow behavior when the user has not moved back.

