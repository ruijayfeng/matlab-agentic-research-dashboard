function app = runCryptoDashboard()
%RUNCRYPTODASHBOARD Launch the AI crypto asset dashboard.
    appDir = fullfile(fileparts(mfilename("fullpath")), "app");
    if contains(path, appDir)
        rmpath(appDir);
    end
    addpath(appDir, "-begin");
    rehash;
    clear("CryptoAssetDashboardApp");
    app = CryptoAssetDashboardApp();
end
