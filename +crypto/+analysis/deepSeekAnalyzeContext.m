function result = deepSeekAnalyzeContext(context, apiKey, model)
%DEEPSEEKANALYZECONTEXT Call DeepSeek chat completions for AI analysis.
    arguments
        context struct
        apiKey (1,1) string = crypto.config.getApiKey("DEEPSEEK")
        model (1,1) string = "deepseek-v4-flash"
    end

    if strlength(apiKey) == 0
        result = localFallback("missing-api-key", "DeepSeek 不可用：缺少 DEEPSEEK_API_KEY。");
        return
    end

    try
        request = struct();
        request.model = model;
        request.messages = crypto.analysis.deepSeekMessages(context);
        request.temperature = 0.2;
        request.max_tokens = 900;
        options = weboptions( ...
            "MediaType", "application/json", ...
            "HeaderFields", {'Authorization', char("Bearer " + apiKey)}, ...
            "Timeout", 45);
        response = webwrite("https://api.deepseek.com/chat/completions", request, options);
        text = string(response.choices(1).message.content);
        result = struct();
        result.Provider = "deepseek";
        result.Model = model;
        result.GeneratedAt = datetime("now", "TimeZone", "Asia/Shanghai");
        result.Highlights = strings(0, 1);
        result.Text = "AI 分析" + newline + "分析来源: DeepSeek" + newline + "模型: " + model + newline + text;
        result.LLMAdapter = struct("Status", "ok", "ExpectedInput", "context.LLMPayload");
    catch err
        result = localFallback("api-error", "DeepSeek 不可用：" + string(err.message));
    end
end

function result = localFallback(status, text)
    result = struct();
    result.Provider = "local-rules";
    result.Model = "";
    result.GeneratedAt = datetime("now", "TimeZone", "Asia/Shanghai");
    result.Highlights = strings(0, 1);
    result.Text = text;
    result.LLMAdapter = struct("Status", status, "ExpectedInput", "context.LLMPayload");
end
