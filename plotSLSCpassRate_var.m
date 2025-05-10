function plotSLSCpassRate_var(res, th)
% th : table with columns N, fit, value  (gen 列は使わない前提)

genList = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"];
fitList = genList;
Nlist   = [50 100 150];

figure('Position',[100 100 1200 350]);

for nIdx = 1:numel(Nlist)
    Nfld = "N" + Nlist(nIdx);
    M    = zeros(numel(genList));        % 6×6

    for gi = 1:numel(genList)
        for fi = 1:numel(fitList)
            pairFld = genList(gi) + "2" + fitList(fi);

            % ---- 1) しきい値をテーブル th から取得 -----------------
            idxTH = th.N == Nlist(nIdx) & th.fit == fitList(fi);
            if any(idxTH)
                thr = th.value(find(idxTH,1,'first'));   % 該当行の値
            else
                thr = 0.04;         % fallback
            end

            % ---- 2) データ存在チェック & pass rate -----------------
            if isfield(res, pairFld) && isfield(res.(pairFld), Nfld)
                vec      = res.(pairFld).(Nfld);
                M(gi,fi) = mean(vec < thr);
            else
                M(gi,fi) = NaN;     % 欠損
            end
        end
    end

    % ---- 3) ヒートマップ描画 ---------------------------------------
    subplot(1,3,nIdx);
    heatmap(fitList, genList, M, ...
            'Colormap', parula, ...
            'ColorLimits', [0 1], ...
            'MissingDataColor',[0.8 0.8 0.8], ...
            'CellLabelFormat','%.2f');
    title("N = " + Nlist(nIdx));
    xlabel("fit model"); ylabel("generator model");
end
sgtitle("Pass rate: P(SLSC < threshold(N, fit))");
end