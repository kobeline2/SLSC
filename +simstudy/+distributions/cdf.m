function y = cdf(model, x, theta)
% cdf dispatcher
% Inputs
% model    : 'sqrtet',...
% x        : numeric array  – evaluation points
% theta    : struct (e.g., struct('mu',0,'sigma',1) for 'normal')
%
% Output
%   y        : numeric array  – same size as x, CDF values
% 
% Example:
%   y = simstudy.distributions.cdf("sqrtet", x, theta);

arguments
    model
    x                         {mustBeNumeric}
    theta struct = struct()   
end

funcName = "simstudy.distributions.cdf_" + model;

if isempty(which(funcName))
    error("simstudy:cdf", "Unknown distribution %s", model);
end

y = feval(funcName, theta, x);
end