# MATLAB Agentic Research Dashboard

> A MATLAB-native multi-asset research dashboard powered by agentic analysis.

[![MATLAB](https://img.shields.io/badge/MATLAB-Agentic%20Research-orange)](https://www.mathworks.com/products/matlab.html)
[![Finance](https://img.shields.io/badge/Finance-Multi--Asset-blue)](#key-features)
[![Agentic AI](https://img.shields.io/badge/Agentic%20AI-Research%20Dashboard-green)](#key-features)
[![Tests](https://img.shields.io/badge/tests-41%20passed-brightgreen)](#testing-status)

**Language:** [中文 README](README.md) | [English README](README_EN.md)

## Keywords

`MATLAB` · `agentic AI` · `multi-asset research` · `quantitative finance` · `portfolio risk` · `technical analysis` · `crypto dashboard` · `investment research` · `DeepSeek` · `financial technology`

## Use Cases

- Fintech experiments, research prototypes, and personal research tools
- Multi-asset market monitoring and investment research prototypes
- Crypto, ETF, and gold cross-asset linkage analysis
- Portfolio risk, stress testing, and position management education
- Local Agentic AI workflows for financial research
- DeepSeek and MATLAB hybrid analysis demos

## Why This Project

- MATLAB-native implementation with no heavy web frontend dependency
- End-to-end workflow from market data to agentic research recommendations
- Explainable Agent cluster instead of one black-box text output
- Tested MATLAB package structure using `matlab.unittest`
- Easy to extend with equities, macro data, news, backtesting, or external Agent services

## Overview

MATLAB Agentic Research Dashboard is a desktop research workbench built with MATLAB UI components and package-based modules. It monitors crypto and cross-asset markets, calculates technical and portfolio risk metrics, and uses a MATLAB-native Agent cluster to convert structured market evidence into readable research guidance.

## Key Features

- Multi-asset dashboard: `BTCUSDT`, `ETHUSDT`, `SOLUSDT`, `SPY`, `QQQ`, `GLD`, `USDT`
- Technical indicators: MA20, MA50, MACD, RSI14, returns, volatility, anomaly detection
- Portfolio tools: editable holdings, PnL, allocation, import/export
- Risk analysis: risk contribution, correlation, strategy scores, stress tests
- MATLAB-native Agent cluster:
  - DataQualityAgent
  - TechnicalAgent
  - PortfolioRiskAgent
  - MacroLinkageAgent
  - CriticAgent
- Integrated recommendation:
  - Market view
  - Position guidance
  - Add/reduce suggestions
  - Watch triggers
- Optional DeepSeek report with local deterministic fallback
- MATLAB unit tests

## Quick Start

Run the app from the MATLAB project root:

```matlab
runCryptoDashboard
```

Run diagnostics:

```matlab
diagnoseCryptoDashboard
```

Run tests:

```matlab
runtests("tests")
```

Or from PowerShell:

```powershell
matlab -batch "runtests('tests')"
```

## Architecture

```text
app/                  Main MATLAB UI application
+crypto/+agents       Agent cluster and recommendation rendering
+crypto/+analysis     Research context, risk, strategy, LLM payload
+crypto/+data         Market data adapters and cache
+crypto/+indicators   Technical indicators
+crypto/+portfolio    Holdings, PnL, allocation, risk narrative
tests/                MATLAB unit tests
docs/                 Reports and design documents
```

## API Keys

Optional environment variables:

```matlab
setenv("DEEPSEEK_API_KEY", "your-key")
setenv("FMP_API_KEY", "your-key")
setenv("ALPHAVANTAGE_API_KEY", "your-key")
```

Or create `config.local.json` in the project root:

```json
{
  "DEEPSEEK_API_KEY": "your-key",
  "FMP_API_KEY": "your-key",
  "ALPHAVANTAGE_API_KEY": "your-key"
}
```

Do not commit API keys.

## Testing Status

Latest local verification:

```text
41 Passed, 0 Failed, 0 Incomplete
```

## Disclaimer

This project is for education, research, and software engineering practice. It does not provide financial advice and should not be used as an automated trading system.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
