function messages = deepSeekMessages(context)
%DEEPSEEKMESSAGES Build chat messages from MATLAB analysis context.
    arguments
        context struct
    end

    payloadJson = jsonencode(context.LLMPayload);
    systemText = [
        "You are an AI portfolio risk analyst inside a MATLAB multi-asset dashboard.";
        "Use only the provided structured context. Do not invent prices, holdings, or news.";
        "Your job is to explain how current holdings connect to risk contribution, cross-asset correlation, volatility regime, and relative strength.";
        "You must also use the MATLAB strategy scorecard to explain price action, trend, mean reversion, cross-asset linkage, portfolio impact, and valuation.";
        "Explain why the highest and lowest composite score assets differ, and how that should affect the portfolio view.";
        "Write in concise Chinese for a dashboard text area. Avoid Markdown tables. Avoid long paragraphs.";
        "Every section must refer to at least one MATLAB-calculated metric, such as allocation, risk contribution, average correlation, 20D return, volatility percentile, strategy scores, or signal tags.";
        "Avoid investment guarantees. Use risk-management language, not trading commands."
        ];
    userText = [
        "Analyze this MATLAB-generated multi-asset context for BTC, ETH, SOL, SPY, QQQ, and GLD.";
        "Return exactly these sections with short bullets:";
        "1. Summary";
        "2. Holdings Link";
        "3. Key Risks";
        "4. Cross-Asset Read";
        "5. Portfolio Action Points";
        "6. Watchlist";
        "Keep the whole report under 18 bullets.";
        "Structured context JSON:";
        payloadJson
        ];

    messages = struct( ...
        "role", {"system", "user"}, ...
        "content", {strjoin(systemText, newline), strjoin(userText, newline)});
end
