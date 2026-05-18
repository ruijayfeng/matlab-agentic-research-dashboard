# Crypto Asset Intelligence Dashboard Design

## Product Scope

Build a MATLAB desktop dashboard for BTC, ETH, and SOL market monitoring and asset research. The first version focuses on Binance public spot market data, MATLAB-native charts, technical indicators, lightweight AI-style analysis generated from MATLAB calculations, portfolio tracking, and CSV/XLSX export.

## Assets

- BTCUSDT
- ETHUSDT
- SOLUSDT

No generic coin search, exchange selection, trading execution, or order placement is included in the first version.

## Architecture

The app is split into focused MATLAB packages:

- `+crypto/data`: fetches and normalizes Binance public market data.
- `+crypto/indicators`: computes MA, MACD, RSI, returns, volatility, and anomalies.
- `+crypto/analysis`: converts numeric results into structured insight text for the dashboard.
- `+crypto/portfolio`: calculates holdings value, PnL, and allocation.
- `+crypto/export`: writes tables and analysis summaries to CSV or Excel.
- `app/CryptoAssetDashboardApp.m`: programmatic `uifigure` app that wires UI controls to package functions.

## Data Flow

1. The app requests 24h tickers and K-line candles for BTCUSDT, ETHUSDT, and SOLUSDT.
2. Raw Binance JSON is normalized into MATLAB tables with typed numeric columns.
3. Indicator functions add MA, MACD, RSI, returns, realized volatility, and anomaly flags.
4. Analysis functions produce deterministic market summaries from the calculated values.
5. The dashboard renders market cards, K-line/indicator plots, an AI analysis panel, and a lightweight portfolio table.
6. Export functions write current data and analysis to disk.

## AI Native Behavior

The first version does not let an LLM guess from raw prompts. MATLAB performs the calculations first, then the app creates a structured "AI analysis" brief from those facts:

- trend direction from MA and recent returns
- momentum from RSI and MACD
- volatility regime from return z-scores
- abnormal candle/volume events
- cross-asset relative strength
- portfolio exposure and PnL notes

This keeps the analysis explainable and testable. A later version can send the structured analysis pack to an LLM API for richer wording.

## Error Handling

- Network fetch failures return readable errors in the app status area.
- Binance response parsing validates required fields.
- Indicator functions handle short series by returning `NaN` where periods are unavailable.
- Portfolio calculations accept empty holdings and missing prices.

## Testing

Unit tests cover indicator calculations, analysis summary generation, portfolio calculations, and export path behavior. Live Binance calls are verified separately because they depend on network availability.

