# AI Analysis Context Design

## Goal

Add an AI Analysis foundation for the MATLAB multi-asset dashboard that emphasizes portfolio risk, cross-asset relationships, and structured context rather than more ordinary quote UI.

## Scope

The first version covers BTCUSDT, ETHUSDT, SOLUSDT, SPY, QQQ, and GLD. USDT remains available as cash for portfolio math but is excluded from cross-asset risk analytics.

## Architecture

The analysis layer is split into two MATLAB package functions:

- `crypto.analysis.buildContext(tickers, marketCandles, portfolio)` builds a deterministic struct containing market snapshot tables, technical state tables, correlation data, risk contribution tables, signals, and an LLM-ready payload.
- `crypto.analysis.analyzeContext(context)` consumes the struct and returns local rule-based AI text plus machine-readable highlights.

The App keeps UI changes small: it gathers analysis candles, builds context after portfolio refresh, and renders the local-rule narrative in the existing AI analysis text area.

## Metrics

The context prioritizes MATLAB-native strengths:

- Matrix-based return correlation across BTC, ETH, SOL, SPY, QQQ, and GLD.
- Portfolio allocation and volatility-based risk contribution.
- Rolling volatility, volatility percentile, max drawdown, RSI, MACD, and abnormal-return flags.
- Relative strength ranking from multi-window returns.
- Local rule signals such as concentration risk, crypto risk dominance, risk-on/risk-off tilt, gold hedge behavior, and volatility spikes.

## Future LLM API Boundary

The context includes `LLMPayload`, a serializable struct with versioned tables converted to simple structs. A later LLM adapter can send this payload to an API without changing MATLAB indicator and portfolio calculations.
