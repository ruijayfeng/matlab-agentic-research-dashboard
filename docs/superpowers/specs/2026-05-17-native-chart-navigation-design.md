# Native Chart Navigation Design

## Goal

Improve the MATLAB dashboard chart behavior from a static plot into a usable market-monitoring view while staying inside native MATLAB UI components.

## Interaction Model

- The app loads a larger candle history from Binance.
- The chart displays a configurable visible window: 50, 100, or 200 candles.
- A slider moves the visible window through the loaded candle history.
- `Latest` jumps to the newest candle window and re-enables follow-latest behavior.
- `Reset` restores the current selected window without changing the selected asset or interval.
- Auto refresh preserves the user's history view. If the user is viewing the latest window, new data stays pinned to latest; if the user has moved the slider back, refresh keeps the same relative historical window.

## Scope

This version does not attempt a full OKX-style JavaScript chart. Native MATLAB `uiaxes` remains the rendering surface. Mouse zoom may still depend on MATLAB version support, so the reliable controls are the visible candle dropdown, history slider, `Latest`, and `Reset`.

