function cfg = base()
cfg.seed        = 42;           % 乱数シード
cfg.rep         = 100;          % R
cfg.sampleSize  = 30;           % N
cfg.genDist     = 'normal';     % 真の分布 (後で上書き)
cfg.rawDirRoot  = "results";
cfg.trueParams = struct( ...                                                    % true parameter(kyoto rainfall)
    'normal',       struct('mu',0,'sigma',1), ...                               % [mu, sigma+]
    'lgamma',       struct('a',26.7121,'b',2.4696,'c',50.1637), ...             % [a:scale, b:shape, c:position]
    'sqrtet',       struct('a',190.2683,'b',0.5685), ...                         % [a, b]
    'gumbel',       struct('alpha',97.7438,'beta',30.7042), ...                 % [alpha, beta]
    'gev',          struct('k',0.0910, 'sigma',29.5452 , 'mu',96.2345), ...     % [k, sigma+, mu]
    'lnormal',      struct('c',31.3965, 'mu',4.3254 , 'sigma',0.4837), ...      % [c, mu, sigma+] 
    'exponential',  struct('c',54.4999,'mu',61.6321));                          % [c, mu+]
cfg.genList  = {'normal', 'lgamma', 'sqrtet', 'gumbel',...
                'gev', 'lnormal', 'exponential'};
% 初期値をモデル名キーのサブ struct で持つ
cfg.theta0 = struct( ...                                                   % initial parameter value for estimation
    'normal',       struct('mu',0,'sigma',1), ...                          % [mu, sigma+]
    'lgamma',       struct('a',20,'b',2,'c',50), ...                       % [a:scale, b:shape, c:position]
    'sqrtet',       struct('a',120,'b',0.5), ...                             % [a, b]
    'gumbel',       struct('alpha',100,'beta',30), ...                     % [alpha, beta]
    'gev',          struct('k',0.1, 'sigma',30 , 'mu',100), ...            % [k, sigma+, mu]
    'lnormal',      struct('c',30, 'mu',5 , 'sigma',1), ...                % [c, mu, sigma+] 
    'exponential',  struct('c',50,'mu',50)...                             % [c, mu+]
                   );
cfg.metrics = {'SLSC', 'AIC', 'XENTROPY'};
end
   
