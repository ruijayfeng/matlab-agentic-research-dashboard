function apiKey = getApiKey(provider)
%GETAPIKEY Read API keys from environment variables or config.local.json.
    provider = upper(string(provider));
    envName = provider + "_API_KEY";
    apiKey = string(getenv(char(envName)));
    if strlength(apiKey) > 0
        return
    end

    configPaths = unique([ ...
        string(fullfile(pwd, "config.local.json")); ...
        string(fullfile(localProjectRoot(), "config.local.json")) ...
        ], "stable");

    fieldName = char(envName);
    for idx = 1:numel(configPaths)
        configPath = configPaths(idx);
        if ~isfile(configPath)
            continue
        end
        try
            config = jsondecode(fileread(configPath));
            if isfield(config, fieldName)
                apiKey = string(config.(fieldName));
                if strlength(apiKey) > 0
                    return
                end
            end
        catch
            apiKey = "";
        end
    end
end

function projectRoot = localProjectRoot()
    projectRoot = fileparts(fileparts(fileparts(mfilename("fullpath"))));
end
