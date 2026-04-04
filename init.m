function paths = init()
%INIT Initialize the SLSC project for an interactive MATLAB session.
%
%   paths = init()
%
% Adds the repository root and scripts directory to the MATLAB path,
% creates local-only directories, and returns the resolved paths struct.

repoRoot = fileparts(mfilename("fullpath"));
scriptsDir = fullfile(repoRoot, "scripts");

addpath(repoRoot);
addpath(scriptsDir);

paths = slscLocalPaths(true);

fprintf("Initialized SLSC project.\n");
fprintf("Repository root: %s\n", paths.repoRoot);
fprintf("Scripts        : %s\n", paths.scriptsDir);
fprintf("Local root     : %s\n", paths.localRoot);
end
