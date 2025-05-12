function postCollect(rawDir, outFile)
%POSTCOLLECT  Merge raw rep files into a single aggregate MAT-file.
%
%   simstudy.util.postCollect(rawDir, outFile)
%
%   rawDir  : folder that contains   rep####.mat   (each has 'metrics', 'fitRes'…)
%   outFile : path to save aggregate.mat   (created/overwritten)
%
%   Result
%       • allMetrics : struct-of-arrays   →  allMetrics.slsc(i), allMetrics.aic(i), …
%       • fitArray   : 1×R struct array   →  each element is fitRes (optional, heavy)
%
%   Notes
%       – 異なる実験グリッドごとに rawDir を分けておくと集約が簡単です
%       – 追加メトリクスがあっても fieldnames の動的ループで自動対応します

% ----------------------------------------------------------------------
files = dir(fullfile(rawDir,'rep*.mat'));
R     = numel(files);
if R == 0
    warning("postCollect:NoFiles","No rep*.mat in %s", rawDir);
    return
end

% ---------- first pass: discover metric field names -------------------
tmp     = load(fullfile(files(1).folder, files(1).name), 'metrics');
metricNames = fieldnames(tmp.metrics);
% ---------- preallocate struct-of-arrathetaArray(R,1) = struct();
allMetrics = struct();
% ----- 1 回だけ読み込んでテンプレートを作る ----------
tmp1 = load(fullfile(files(1).folder, files(1).name), 'fitRes');
tmpl = tmp1.fitRes.theta;          % フィールドがそろった構造体
thetaArray = repmat(tmpl, R, 1);   % フィールド付きで確保済み
for k = 1:numel(metricNames)
    key = metricNames{k};
    allMetrics.(key) = zeros(R,1);
end

for i = 1:R
    S = load(fullfile(files(i).folder, files(i).name), ...
             'metrics', 'fitRes');

    % ---- metrics をベクトル化 --------------------------
    fn = fieldnames(S.metrics);
    for k = 1:numel(fn)
        key = fn{k};
        if ~isfield(allMetrics,key)
            allMetrics.(key) = zeros(R,1);
        end
        allMetrics.(key)(i) = S.metrics.(key);
    end

    % ---- thetaArray を追加 -----------------------------
    thetaArray(i,1) = S.fitRes.theta;  
end

save(outFile, 'allMetrics', 'thetaArray', '-v7.3');  
fprintf("Aggregated %d files → %s\n", R, outFile);
end