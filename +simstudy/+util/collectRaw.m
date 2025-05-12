function collectRaw(root, pattern)
%COLLECTRAW  Run post-processing (postCollect) for every raw folder found.
% Rawはあるときにaggregate.matだけ作り直す
% 
%   simstudy.util.collectRaw(root)
%   simstudy.util.collectRaw(root, pattern)
%
%   root    : top folder that contains   <tag>/raw/rep####.mat
%   pattern : optional regular expression to filter tag names
%
%   For each  <root>/<tag>/raw  it creates (or overwrites)
%             <root>/<tag>/aggregate.mat
%   using simstudy.util.postCollect.
%
%   Example
%     simstudy.util.collectRaw("results");                % 全て
%     simstudy.util.collectRaw("results","^N50_.*$");     % N50 だけ

arguments
    root    string = "results"
    pattern string = ".*"          % default: match all
end

rawFolders = dir(fullfile(root,"**","raw"));
rawFolders = rawFolders([rawFolders.isdir]);

fprintf("Scanning '%s' ...\n", root);

for k = 1:numel(rawFolders)
    tag = erase(rawFolders(k).folder, root+filesep);
    if isempty(regexp(tag, pattern,'once')), continue, end

    rawDir  = rawFolders(k).folder;
    outFile = fullfile(fileparts(rawDir),"aggregate.mat");

    fprintf("  • %s  →  aggregate.mat\n", tag);
    simstudy.util.postCollect(rawDir, outFile);
end

fprintf("Done.\n");
end