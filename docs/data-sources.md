# Data Sources

## Current Live Sources

- Binance Spot public market data: BTCUSDT, ETHUSDT, SOLUSDT.
- Synthetic cash row: USDT = 1.

## Optional Cross-Asset Sources

Stooq is the preferred no-key source for SPY, QQQ, and GLD rows in portfolio, market overview, and the Cross-Asset Daily chart tab.
FMP and Alpha Vantage remain available as fallback adapters.
They are not part of the crypto intraday K-line selector. Crypto Intraday stays on BTC/ETH/SOL; Cross-Asset Daily handles SPY/QQQ/GLD.

Set the key before launching MATLAB or inside MATLAB:

```matlab
setenv("ALPHAVANTAGE_API_KEY", "your_key_here")
setenv("FMP_API_KEY", "your_key_here")
clear classes
runCryptoDashboard
```

The project also supports a local `config.local.json` file in the project root:

```json
{
  "ALPHAVANTAGE_API_KEY": "your_key_here",
  "FMP_API_KEY": "your_key_here"
}
```

`config.local.json` is ignored by Git.

Without this key, the app keeps only BTCUSDT, ETHUSDT, SOLUSDT, and USDT active.

Stooq, FMP, and Alpha Vantage responses are cached under `cache/` and reused for 18 hours.

## Future Sources

- China equity indices are represented in `crypto.assets.universe()` but remain inactive until an A-share adapter is added.
- More professional feeds can be added behind the same adapter pattern.
# Local AI API Configuration

DeepSeek AI analysis reads the API key from either:

- Environment variable: `DEEPSEEK_API_KEY`
- Local ignored config file: `config.local.json`

Example `config.local.json` entry:

```json
{
  "DEEPSEEK_API_KEY": "your-new-deepseek-key"
}
```

`config.local.json` is ignored by git in this project. Do not commit API keys.
