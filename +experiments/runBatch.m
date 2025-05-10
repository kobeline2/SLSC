function runBatch(cfg)

for gen = cfg.genList
for fit = cfg.fitList
for N   = cfg.Nlist

    tag   = sprintf("N%d_%s2%s",N,gen,fit);
    rawDir = fullfile("results",tag,"raw");
    % -------- clean-up if the folder already exists -------------------
    if isfolder(rawDir), rmdir(rawDir, 's'); end; mkdir(rawDir);     

    parfor r = 1:cfg.rep
        % --- reproducible stream ------------------------------------
        rs = RandStream('Threefry','Seed',cfg.seed); rs.Substream = r;
        % --- sample -------------------------------------------------
        obs   = simstudy.distributions.rnd(gen, N, cfg.trueParams.(gen));
        % --- MLE ----------------------------------------------------
        theta0 = cfg.theta0.(fit);
        fitRes = simstudy.estimators.MLE(fit, obs, theta0);
        % --- metrics (dynamic) -------------------------------------
        metricsList = reshape(cfg.metrics,1,[]);
        metrics = struct();
        for mi = 1:numel(metricsList)
            mName  = metricsList(mi);
            mField = char(lower(mName));
            metrics.(mField) = simstudy.metrics.score(mName, obs, fitRes);
        end
        % --- save ---------------------------------------------------
        simstudy.util.parsave(fullfile(rawDir,sprintf('rep%04d.mat',r)), metrics,fitRes); 
    end
    % --- aggregate --------------------------------------------------
    simstudy.util.postCollect(rawDir,fullfile("results",tag,"aggregate.mat"));
end
end
end