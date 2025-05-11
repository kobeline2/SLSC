function plotSLSCpassRateVar(src, th, opts)
%PLOTSLSCPASSRATEVAR  Heat-maps of P(SLSC < τ(N,fit)) for variable τ.
%
%   simstudy.analysis.plotSLSCpassRateVar(src, th)
%   simstudy.analysis.plotSLSCpassRateVar(src, th, opts)
%
%   src  : res structure  *or*  root folder containing tag/aggregate.mat
%   th   : table with columns  N, fit, value   (threshold τ)
%          if not provided, th is fixed to be 0.04.
%   opts (optional) fields
%       .genList : string array of generator models
%       .fitList : string array of fit models   (defaults = genList)
%       .Nlist   : numeric array of sample sizes
%
%   Example
%     opts.genList = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"];
%     opts.Nlist   = [50 100 150];
%     simstudy.analysis.plotSLSCpassRateVar(res, th, opts);

arguments
    src
    th  table
    opts.genList string = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"]
    opts.fitList string = ["exponential","gev","gumbel","lgamma","lnormal","sqrtet"]
    opts.Nlist   double = [50 100 150]
end

genList = opts.genList(:);     % column vectors
fitList = opts.fitList(:);
Nlist   = opts.Nlist(:);

figure('Position',[100 100 300*numel(Nlist) 350]);

for nIdx = 1:numel(Nlist)
    N  = Nlist(nIdx);
    M  = nan(numel(genList), numel(fitList));   % pass-rate matrix
    for gi = 1:numel(genList)
        for fi = 1:numel(fitList)
            pair = genList(gi) + "2" + fitList(fi);

            % ------- τ lookup ----------------------------------------
            idx = th.N == N & th.fit == fitList(fi);
            if ~any(idx), continue, end
            tau = th.value(find(idx,1,'first'));

            % ------- metric vector -----------------------------------
            try
                v   = simstudy.util.getMetric(src, N, pair, "slsc");
                M(gi,fi) = mean(v < tau);
            catch
                % leave as NaN (missing data)
            end
        end
    end

    % ------- heat-map -----------------------------------------------
    subplot(1,numel(Nlist),nIdx);
    heatmap(fitList, genList, M, ...
            'Colormap', turbo, 'ColorLimits',[0 1], ...
            'MissingDataColor',[.85 .85 .85], ...
            'CellLabelFormat','%.2f');
    title("N = "+N);
    xlabel("fit"); ylabel("gen");
end
sgtitle("Pass rate   P(SLSC < τ(N, fit))");
end