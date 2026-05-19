# MATLAB-Native Agent Workbench Design

## Goal

Build a visible Agent cluster experience inside the existing MATLAB multi-asset dashboard. The first version keeps all orchestration inside MATLAB, while making the Agent workflow, conclusions, evidence, disagreements, and action watchlist obvious in the UI.

## Product Direction

The dashboard should no longer feel like a charting app with one AI text box. It should feel like a research desk where several specialized Agents inspect the same market context and publish structured views:

- Data quality and coverage
- Technical state
- Portfolio risk
- Macro and cross-asset linkage
- Critical review
- Consensus and action watchlist

DeepSeek remains optional. The core Agent cluster must work without an API key by using deterministic MATLAB calculations and local rules.

## Scope

In scope:

- Add a MATLAB package under `+crypto/+agents`.
- Define a consistent Agent result structure.
- Add deterministic Agents for data quality, technical analysis, portfolio risk, macro linkage, and critical review.
- Add an orchestrator that runs Agents over the existing `crypto.analysis.buildContext` output.
- Add consensus, disagreement, action watchlist, and evidence log outputs.
- Replace the current AI tab presentation with an `Agent Workbench` view that visibly shows the Agent cluster.
- Add focused MATLAB unit tests.

Out of scope for this version:

- A separate Python or Node Agent service.
- Persistent memory or vector database.
- Streaming token-by-token LLM responses.
- Automated trading or order execution.
- News ingestion.

## Agent Result Contract

Each Agent returns a scalar struct with these fields:

```matlab
result = struct( ...
    "Name", "TechnicalAgent", ...
    "Role", "Technical market analysis", ...
    "Status", "completed", ...
    "Confidence", 0.72, ...
    "Headline", "趋势偏强，但动量过热", ...
    "Evidence", ["BTC 高于 MA20"; "RSI 接近过热"], ...
    "Risks", ["追涨风险上升"], ...
    "Recommendation", "持有为主，等待回调", ...
    "Timestamp", datetime("now", "TimeZone", "Asia/Shanghai"));
```

`Status` values:

- `completed`
- `warning`
- `failed`
- `skipped`

`Confidence` is a number from `0` to `1`.

## Research Run Contract

The orchestrator returns:

```matlab
run = struct( ...
    "RunId", "agent-run-20260519-162500", ...
    "ContextVersion", "ai-analysis-context-v1", ...
    "StartedAt", datetime("now", "TimeZone", "Asia/Shanghai"), ...
    "CompletedAt", datetime("now", "TimeZone", "Asia/Shanghai"), ...
    "AgentResults", agentResults, ...
    "Consensus", ["..."], ...
    "Disagreements", ["..."], ...
    "ActionWatchlist", ["..."], ...
    "EvidenceLog", ["..."]);
```

The UI reads only this contract. Individual Agent internals can change without rewriting UI code.

## Agents

### DataQualityAgent

Checks whether market, technical, correlation, and portfolio evidence is usable.

Signals warning when:

- Market snapshot is missing or empty.
- Technical state has fewer than three assets.
- Correlation matrix is unavailable.
- Portfolio risk table is empty.

### TechnicalAgent

Summarizes trend and momentum from `context.TechnicalState`.

Expected evidence:

- Strongest or weakest asset when available.
- RSI state.
- MACD or moving-average state.

### PortfolioRiskAgent

Summarizes portfolio concentration and risk contribution from `context.RiskContributions`.

Expected evidence:

- Largest risk contributor.
- Crypto risk share when available.
- Largest allocation.

### MacroLinkageAgent

Summarizes cross-asset linkage from `context.Correlation`, `context.MarketSnapshot`, and existing market linkage formatters.

Expected evidence:

- Average correlation.
- Crypto versus equity linkage.
- GLD hedge behavior when detectable.

### CriticAgent

Reviews the preceding Agent outputs and downgrades overconfident or under-evidenced conclusions.

Expected behavior:

- Warn when multiple Agents have low confidence.
- Warn when DataQualityAgent reports missing data.
- Warn when TechnicalAgent is bullish while PortfolioRiskAgent reports high concentration.
- Otherwise confirm the research run has no major contradiction.

## UI Design

Rename or visually retitle the current `AI分析` tab as `Agent Workbench`.

The tab uses four zones:

1. Flow strip
   - Shows `Data -> Technical -> Risk -> Macro -> Critic -> Consensus`.
   - Each step displays status text and confidence.

2. Agent cards
   - One card per Agent.
   - Each card shows name, status, headline, confidence, evidence, risks, and recommendation.

3. Consensus panel
   - Shows common conclusion, disagreement, and action watchlist.

4. Evidence panel
   - Shows evidence log and the existing DeepSeek/local report.

This version may use MATLAB `uitable` and `uitextarea` controls instead of custom card drawing if that is more robust. The key requirement is that the Agent cluster is visible and scannable.

## Data Flow

1. Dashboard refreshes market data.
2. Portfolio is recalculated.
3. Existing analysis context is built with `crypto.analysis.buildContext`.
4. `crypto.agents.runResearchAgents(context)` runs deterministic Agents.
5. UI renders the research run.
6. Optional DeepSeek analysis can still prepend or supplement the narrative report.

## Testing

Add `tests/TestAgents.m` with deterministic context fixtures.

Required test coverage:

- Orchestrator returns five Agent results and the aggregate fields.
- Agent result structs contain the required fields with valid confidence values.
- DataQualityAgent warns on missing context sections.
- CriticAgent flags a conflict between bullish technical analysis and concentrated portfolio risk.
- Consensus output includes action watchlist and evidence log lines.

## Migration Notes

Existing functions under `+crypto/+analysis` remain useful and should not be removed. The Agent layer wraps them into a clearer research workflow.

Existing DeepSeek integration remains optional. It should use the same context and, later, can consume the Agent run as additional evidence.
