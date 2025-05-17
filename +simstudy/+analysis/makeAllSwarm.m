function makeAllSwarm(src, metric, Nlist, outDir, opts)
%MAKEALLSWARM  Make swarmchart for *all* gen→fit pairs and save as PNG.
%
%   simstudy.analysis.makeAllSwarm(src, metric, Nlist, outDir)
%   simstudy.analysis.makeAllSwarm(src, metric, Nlist, outDir, opts)
%
%   Inputs
%     src     : res 構造体  または  root フォルダ
%     metric  : string            e.g. "slsc"
%     Nlist   : numeric array     e.g. [50 100 150]
%     outDir  : output directory  (created if absent)
%     opts    : name-value
%         'genList'   string array (default = all 6 models)
%         'fitList'   string array (default = genList)
%         'Quantiles' double array  (default = [0.1 0.5 0.9])
%         'Overwrite' logical       (default = false)
%

arguments
    src
    metric   string
    Nlist    double  {mustBeVector}
    outDir   string
    opts.genList   string = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"]
    opts.fitList   string = opts.genList
    opts.Quantiles double = [0.1 0.5 0.9]
    opts.Overwrite logical = false
end

% ── 準備 ─────────────────────────────────────────────
if ~isfolder(outDir), mkdir(outDir); end
genList = opts.genList(:);   fitList = opts.fitList(:);

% ── ループ ─────────────────────────────────────────
for gi = 1:numel(genList)
    for fi = 1:numel(fitList)
        pair = genList(gi) + "2" + fitList(fi);

        pngFile = fullfile(outDir, metric, pair + "_violin.png");
        if ~opts.Overwrite && isfile(pngFile)
            fprintf("Skip (exists): %s\n", pngFile); continue
        end
        if ~isfolder(fullfile(outDir, metric)), mkdir(fullfile(outDir, metric)); end

        % ---- 個別プロット ------------------------------------------
        simstudy.analysis.plotMetricViolin(src, genList(gi), fitList(fi), ...
            metric, Nlist, ...
            'Quantiles', opts.Quantiles);

        % ---- PNG 保存 ---------------------------------------------
        exportgraphics(gcf, pngFile, 'Resolution', 300);
        close(gcf);
        fprintf("Saved: %s\n", pngFile);
    end
end
end