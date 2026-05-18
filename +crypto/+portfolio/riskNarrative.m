function lines = riskNarrative(summary)
%RISKNARRATIVE Generate deterministic portfolio risk comments.
    lines = strings(0, 1);
    if summary.TotalValue <= 0
        lines(end + 1, 1) = "Portfolio: no active positions entered.";
        return
    end

    if summary.LargestAllocation >= 0.7
        lines(end + 1, 1) = "Concentration risk: " + summary.LargestSymbol + " is above 70% of portfolio value.";
    elseif summary.LargestAllocation >= 0.45
        lines(end + 1, 1) = "Concentration watch: " + summary.LargestSymbol + " is above 45% of portfolio value.";
    else
        lines(end + 1, 1) = "Concentration: no single asset dominates the portfolio.";
    end

    cashRatio = summary.CashValue / summary.TotalValue;
    if cashRatio < 0.05
        lines(end + 1, 1) = "Liquidity: cash buffer is below 5%, so drawdowns leave little dry powder.";
    elseif cashRatio > 0.5
        lines(end + 1, 1) = "Liquidity: more than half the portfolio is in cash.";
    else
        lines(end + 1, 1) = "Liquidity: cash buffer is moderate.";
    end

    if summary.TotalPnLPercent <= -10
        lines(end + 1, 1) = "PnL risk: portfolio drawdown is deeper than 10% from cost.";
    elseif summary.TotalPnLPercent >= 10
        lines(end + 1, 1) = "PnL state: unrealized gain is above 10%, consider position discipline.";
    else
        lines(end + 1, 1) = "PnL state: unrealized result is within a moderate range.";
    end
end
