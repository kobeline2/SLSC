function zipAllRaw(root, method)
%ZIPALLRAW  Compress each <tag>/raw folder with 7-Zip or tar.xz.
%
%   zipAllRaw()                    % root = "results", method = "7z"
%   zipAllRaw("results_alt","xz")  % tar + xz
%
%   • 7z  : raw.7z  （LZMA2 -mx=9, solid）
%   • xz  : raw.tar.xz  （xz -9e, solid）
%
%   raw フォルダは圧縮成功後に削除される。
%   同名アーカイブが既にある場合はスキップ。

if nargin < 1, root = "results"; end
if nargin < 2, method = "7z"; end          % "7z" | "xz"

rawDirs = dir(fullfile(root,"**","raw"));
rawDirs = rawDirs([rawDirs.isdir]);
tagSet  = unique(string({rawDirs.folder}));

logFile = fullfile(root,"zipAllRaw_log.txt");
fid     = fopen(logFile,'a');
fprintf("Found %d raw folders under %s\n", numel(tagSet), root);

for tagDirTemp = tagSet
    tagDir = fileparts(tagDirTemp);
    rawDir = fullfile(tagDir,"raw");

    switch method
        case "7z"
            arcFile = fullfile(tagDir,"raw.7z");
            cmd     = sprintf('/opt/homebrew/bin/7z a -t7z -mx=9 "%s" "%s"', arcFile, rawDir);
        case "xz"
            arcFile = fullfile(tagDir,"raw.tar.xz");
            cmd     = sprintf('tar -c "%s" | xz -9e > s"%s"', rawDir, arcFile);
        otherwise
            error("Unknown method %s",method);
    end

    if isfile(arcFile)
        fprintf(" [skip] %s (archive exists)\n", tagDir); continue
    end

    fprintf("  archiving %-50s", tagDir);
    status = system(cmd);
    if status==0
        rmdir(rawDir,'s');
        fprintf(" done\n");
        fprintf(fid,"[%s] %s -> %s\n", datestr(now,31), rawDir, arcFile);
    else
        warning("zipAllRaw:fail","cmd failed (%s)", cmd);
        fprintf(fid,"[%s] FAIL %s\n", datestr(now,31), tagDir);
    end
end
fclose(fid);
end