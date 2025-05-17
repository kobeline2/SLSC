function addLoocv_fromZip(tagDir)
%ADDLOOCV_FROMZIP  raw.zip を一時展開して LOOCV を追記，再圧縮.
%
%   simstudy.metrics.addLoocv_fromZip("results/N100_gumbel2gumbel")

rawZip = fullfile(tagDir,"raw.zip");
rawDir = fullfile(tagDir,"raw");
aggMat = fullfile(tagDir,"aggregate.mat");

% ---------- locate raw data ------------------------------------------
if isfile(rawZip)
    if ~isfolder(rawDir)
        fprintf("unzip %s ...\n", rawZip);
        unzip(rawZip, tagDir);          % ① 解凍
    else
        fprintf("using existing raw/ folder (zip also present)\n");
    end
elseif isfolder(rawDir)
    fprintf("raw.zip not found – using raw/ as is\n");
else
    error("Neither raw.zip nor raw/ found in %s", tagDir);
end

% ---------- aggregate.mat check --------------------------------------
if ~isfile(aggMat)
    error("aggregate.mat not found in %s", tagDir);
end

S = load(aggMat,"allMetrics");
if isfield(S.allMetrics,"loocv")
    fprintf("skip %s (loocv already exists)\n", tagDir);
    return
end

% ---------- compute LOOCV -------------------------------------------
files = dir(fullfile(rawDir,"rep*.mat"));
rep   = numel(files);   v = NaN(rep,1);

parfor k = 1:rep
    R = load(fullfile(files(k).folder,files(k).name), "obs", "fitRes");
    v(k) = simstudy.metrics.loocv(R.obs, R.fitRes);
end

S.allMetrics.loocv = v;
save(aggMat,"-struct","S");    % ② 追記
fprintf("loocv appended to %s\n", aggMat);

% ---------- re-zip & cleanup ----------------------------------------
if isfile(rawZip)               % zip が元々あった場合：上書き更新
    zipTmp = fullfile(tagDir,"raw_tmp.zip");
    fprintf("re-zip raw → %s ...\n", zipTmp);
    zip(zipTmp, rawDir);
    movefile(zipTmp, rawZip,"f");   % atomic 置き換え
else                             % zip 無かった → 新規作成
    zip(rawZip, rawDir);
end
rmdir(rawDir,'s');               % ③ raw/ 削除
end