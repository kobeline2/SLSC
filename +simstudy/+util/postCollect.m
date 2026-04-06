function postCollect(rawDir, outFile, runMeta)
%POSTCOLLECT  Merge raw rep files into a single aggregate MAT-file.
%
%   simstudy.util.postCollect(rawDir, outFile)
%   simstudy.util.postCollect(rawDir, outFile, runMeta)
%
%   rawDir  : folder that contains   rep####.mat   (each has 'metrics', 'fitRes'…)
%   outFile : path to save aggregate.mat   (created/overwritten)
%
%   runMeta : optional struct with run-level metadata to store once
%
%   Result
%       • allMetrics : struct-of-arrays   →  allMetrics.slsc(i), allMetrics.aic(i), …
%       • thetaArray : R×1 struct array   →  fitted theta for each repetition
%       • exitflagArray : R×1 numeric     →  optimiser exitflag for each repetition
%       • runMeta    : struct             →  shared settings for the tag (optional)
%
%   Notes
%       – 異なる実験グリッドごとに rawDir を分けておくと集約が簡単です
%       – 追加メトリクスがあっても fieldnames の動的ループで自動対応します

if nargin < 3
    runMeta = struct();
end

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
exitflagArray = zeros(R,1);
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
    exitflagArray(i,1) = S.fitRes.exitflag;
end

save(outFile, 'allMetrics', 'thetaArray', 'exitflagArray', 'runMeta', '-v7.3');
fprintf("Aggregated %d files → %s\n", R, outFile);
end
