classdef TestConfig < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPath(testCase)
            testCase.applyFixture(ProjectPathFixture());
        end
    end

    methods (Test)
        function getApiKeyReadsProjectConfigWhenPwdDiffers(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            configPath = fullfile(projectRoot, "config.local.json");
            original = "";
            hadOriginal = isfile(configPath);
            if hadOriginal
                original = string(fileread(configPath));
            end
            cleanup = onCleanup(@() TestConfig.restoreConfig(configPath, hadOriginal, original));
            fid = fopen(configPath, "w");
            fprintf(fid, '{"DEEPSEEK_API_KEY":"test-deepseek-key"}');
            fclose(fid);

            oldPwd = pwd;
            pwdCleanup = onCleanup(@() cd(oldPwd));
            cd(tempdir);

            apiKey = crypto.config.getApiKey("DEEPSEEK");

            testCase.verifyEqual(apiKey, "test-deepseek-key");
        end
    end

    methods (Static, Access = private)
        function restoreConfig(configPath, hadOriginal, original)
            if hadOriginal
                fid = fopen(configPath, "w");
                fprintf(fid, "%s", char(original));
                fclose(fid);
            elseif isfile(configPath)
                delete(configPath);
            end
        end
    end
end
