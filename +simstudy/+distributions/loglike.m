% File: +simstudy/+distributions/loglike.m
% Log-likelihood dispatcher

function ll = loglike(model, data, theta)
% Log-likelihood dispatcher
% Inputs
%   model    : char / string  – distribution identifier
%   data     : numeric array  – sample vector or matrix
%   theta    : struct         – distribution-specific parameters
%
% Output
%   ll       : double         – total log-likelihood (scalar)
%
% Example:
%   ll = simstudy.distributions.loglike("gamma", data, theta);

arguments
    model
    data           {mustBeNumeric}
    theta struct = struct()           % optional (default empty struct)
end

% --- build fully-qualified subfunction name -------------
funcName = "simstudy.distributions.loglike_" + model;

% --- existence check (use WHICH for dotted names) -------
if isempty(which(funcName))
    error("simstudy:loglike", ...
          "Unknown distribution %s", model);
end

% --- delegate to distribution-specific implementation ---
ll = feval(funcName, data, theta);
end