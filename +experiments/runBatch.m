function runBatch(cfg)
logFile = fullfile(cfg.rawDirRoot, "runBatch_log.txt");
fid     = fopen(logFile, 'a');          % 追記モード
for gen = cfg.genList
for fit = cfg.fitList
for N   = cfg.Nlist

    tag   = sprintf("N%d_%s2%s",N,gen,fit);
    rawDir = fullfile(cfg.rawDirRoot,tag,"raw");
    try
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
            simstudy.util.parsave(fullfile(rawDir,sprintf('rep%04d.mat',r)), ...
                                  metrics,fitRes, obs); 
        end
        % --- aggregate --------------------------------------------------
        simstudy.util.postCollect(rawDir,fullfile(cfg.rawDirRoot,tag,"aggregate.mat"));

    catch ME                      %── 組 (gen,fit,N) 全体が失敗
        warning("runBatch:comboFail", ...
            "(gen=%s, fit=%s, N=%d) skipped: %s", gen, fit, N, ME.message);
        fprintf(fid, "[%s] %s : %s\n", datestr(now,'yyyy-mm-dd HH:MM:SS'), ...
                tag, ME.message);
    end
end
end
end