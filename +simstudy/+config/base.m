function cfg = base()
cfg.seed        = 42;           % 乱数シード
cfg.rep         = 100;          % R
cfg.sampleSize  = 30;           % N
cfg.genDist     = 'normal';     % 真の分布 (後で上書き)
cfg.rawDirRoot  = "results";
cfg.trueParams = struct( ...                                                    % true parameter(kyoto rainfall)
    'normal',       struct('mu',0,'sigma',1), ...                               % [mu, sigma+]
    'lgamma',       struct('a',26.71205642,'b',2.469607287,'c',50.16371005), ... % [a:scale, b:shape, c:position]
    'lp3',          struct('a',0.0682748209,'b',24.33142411,'c',3.035243513), ... % [a:log-scale, b:shape, c:log-position]
    'sqrtet',       struct('a',190.2682759,'b',0.5685454318), ...                % [a, b]
    'gumbel',       struct('alpha',97.7437632,'beta',30.70421841), ...          % [alpha, beta]
    'gev',          struct('k',0.09098607446, 'sigma',29.5452261 , 'mu',96.23447038), ... % [k, sigma+, mu]
    'lnormal',      struct('c',31.39651871, 'mu',4.325409394 , 'sigma',0.4804608172), ... % [c, mu, sigma+] 
    'exponential',  struct('c',54.5,'mu',61.632));                              % [c, mu+]
cfg.genList  = {'normal', 'lgamma', 'lp3', 'sqrtet', 'gumbel',...
                'gev', 'lnormal', 'exponential'};
% 初期値をモデル名キーのサブ struct で持つ
cfg.theta0 = struct( ...                                                   % initial parameter value for estimation
    'normal',       struct('mu',0,'sigma',1), ...                          % [mu, sigma+]
    'lgamma',       struct('a',20,'b',2,'c',50), ...                       % [a:scale, b:shape, c:position]
    'lp3',          struct('a',0.07,'b',20,'c',3.0), ...                   % [a:log-scale, b:shape, c:log-position]
    'sqrtet',       struct('a',120,'b',0.5), ...                             % [a, b]
    'gumbel',       struct('alpha',100,'beta',30), ...                     % [alpha, beta]
    'gev',          struct('k',0.1, 'sigma',30 , 'mu',100), ...            % [k, sigma+, mu]
    'lnormal',      struct('c',30, 'mu',5 , 'sigma',1), ...                % [c, mu, sigma+] 
    'exponential',  struct('c',50,'mu',50)...                             % [c, mu+]
                   );
cfg.metrics = {'SLSC', 'SLSC_X', 'AIC', 'XENTROPY'};
cfg.slscProfile = "japan_admin"; % {japan_admin, eva_reduced}
cfg.slscTransforms = struct();
end
   
