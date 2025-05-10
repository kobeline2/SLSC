function r = rnd(model, N, theta)
% rnd dispatcher
% model    : 'normal', 'gumbel',... 
% N        : sample size
% theta    : struct (e.g., struct('mu',0,'sigma',1) for 'normal')
%
% Example:  x = simstudy.distributions.rnd('A', 500, theta);

arguments
    model
    N (1,1) {mustBeInteger, mustBePositive}        % 必須
    theta struct = struct()                        % 任意
end

funcName = "simstudy.distributions.rnd_" + model;

if isempty(which(funcName))
    error("simstudy:sample","Unknown distribution %s",model);
end

r = feval(funcName, theta, N);
end