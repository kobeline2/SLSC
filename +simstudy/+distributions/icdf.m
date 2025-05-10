% File: +simstudy/+distributions/icdf.m
% Inverse CDF dispatcher
%

function x = icdf(model, u, theta)
% Inverse CDF dispatcher
% Inputs
%   model : char / string   – distribution ID ('gamma', etc.)
%   u     : numeric array   – values in (0,1)
%   theta : struct          – parameters
%
% Output
%   x     : numeric array   – quantiles F^{-1}(u)
%
% Example:
%   x = simstudy.distributions.icdf("gamma", theta, u);

arguments
    model
    u           {mustBeNumeric, mustBeGreaterThan(u,0), mustBeLessThan(u,1)}
    theta       struct = struct()
end

funcName = "simstudy.distributions.icdf_" + model;

if isempty(which(funcName))
    error("simstudy:icdf","Unknown distribution %s",model);
end

x = feval(funcName, theta, u);
end