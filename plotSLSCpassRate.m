function plotSLSCpassRate(res)
%PLOTSLSCPASSRATE  6×6 heatmaps of P(SLSC < 0.04) for N=50,100,150
%
%   plotSLSCpassRate(res)
%
%   res : structure
%         res.<gen>2<fit>.N50 / N100 / N150 .slsc  (vector)

genList = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"];
fitList = genList;
Nlist   = [50 100, 150];

figure('Position',[100 100 1200 350]);

for nIdx = 1:numel(Nlist)
    Nfld = "N" + Nlist(nIdx);
    M    = zeros(numel(genList));          % 6×6 matrix

    for gi = 1:numel(genList)
        for fi = 1:numel(fitList)
            pairFld = genList(gi) + "2" + fitList(fi);
            if isfield(res, pairFld) && isfield(res.(pairFld), Nfld)
                vec = res.(pairFld).(Nfld);
                M(gi,fi) = mean(vec < 0.04);   % pass rate
            else
                M(gi,fi) = NaN;                % 欠損は NaN
            end
        end
    end

    % ---- heatmap ----------------------------------------------------
    subplot(1,3,nIdx);
    h = heatmap(fitList, genList, M, ...
                'Colormap', parula, ...
                'ColorLimits', [0 1], ...
                'MissingDataColor', [0.8 0.8 0.8], ...
                'CellLabelFormat', '%.2f');
    title("N = " + Nlist(nIdx));
    xlabel("fit model"); ylabel("generator model");
end

sgtitle("Pass rate: proportion of SLSC < 0.04");
end