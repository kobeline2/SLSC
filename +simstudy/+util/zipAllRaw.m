function zipAllRaw(root)
%ZIPALLRAW  Compress every <tag>/raw folder in <root> into raw.zip.
%
%   zipAllRaw()              % root = "results" (default)
%   zipAllRaw("results_alt") % 指定フォルダ
%
%   動作:
%     results/N50_gev2gev/raw/rep0001.mat ...
%       ↓ zip
%     results/N50_gev2gev/raw.zip
%     results/N50_gev2gev/raw/   ← 自動削除
%
%   • 既に raw.zip が存在するタグはスキップ
%   • エラー時は警告を表示して続行

if nargin < 1, root = "results"; end
rawDirs = dir(fullfile(root,"**","raw"));
rawDirs = rawDirs([rawDirs.isdir]);

fprintf("Found %d raw folders under %s\n", numel(rawDirs), root);

for k = 1:numel(rawDirs)
    rawDir  = rawDirs(k).folder;         % …/<tag>/raw
    tagDir  = fileparts(rawDir);         % …/<tag>
    zipFile = fullfile(tagDir, "raw.zip");

    if isfile(zipFile)
        fprintf("  [skip] %s (raw.zip already exists)\n", tagDir);
        continue
    end

    try
        fprintf("  → zipping %s ... ", rawDir);
        zip(zipFile, rawDir);            % 圧縮
        rmdir(rawDir, 's');              % raw フォルダ削除
        fprintf("done\n");
    catch ME
        warning("zipAllRaw:fail", "Failed at %s : %s", tagDir, ME.message);
    end
end
end