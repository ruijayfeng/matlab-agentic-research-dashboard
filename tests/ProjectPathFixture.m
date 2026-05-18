classdef ProjectPathFixture < matlab.unittest.fixtures.Fixture
    properties (Access = private)
        OriginalPath string
    end

    methods
        function setup(fixture)
            fixture.OriginalPath = string(path);
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            addpath(projectRoot, "-begin");
        end

        function teardown(fixture)
            path(char(fixture.OriginalPath));
        end
    end
end
