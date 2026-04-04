function paths = slscLocalPaths(makeDirs)
%SLSCLOCALPATHS Resolve local-only directories for data, runs, and exports.
%
%   paths = slscLocalPaths()
%   paths = slscLocalPaths(makeDirs)
%
% Environment variable:
%   SLSC_LOCAL_ROOT
%       If set, local outputs are stored there.
%       Otherwise, <repo>/local is used.

if nargin == 0
    makeDirs = true;
end

thisFile = mfilename("fullpath");
scriptsDir = fileparts(thisFile);
repoRoot = fileparts(scriptsDir);

localRoot = string(getenv("SLSC_LOCAL_ROOT"));
if strlength(localRoot) == 0
    localRoot = fullfile(repoRoot, "local");
end

paths = struct();
paths.repoRoot = string(repoRoot);
paths.scriptsDir = string(scriptsDir);
paths.localRoot = string(localRoot);
paths.dataDir = fullfile(localRoot, "data");
paths.runsDir = fullfile(localRoot, "runs");
paths.validationDir = fullfile(localRoot, "validation");
paths.exportsDir = fullfile(localRoot, "exports");
paths.scratchDir = fullfile(localRoot, "scratch");

if makeDirs
    values = struct2cell(paths);
    for i = 1:numel(values)
        p = values{i};
        if contains(p, localRoot) && ~isfolder(p)
            mkdir(p);
        end
    end
end
end
