function y = pdf(model, x, theta)
% pdf dispatcher
% Inputs
% model    : 'normal', 'gumbel, ...
% x        : numeric array  – evaluation points
% theta    : struct (e.g., struct('mu',0,'sigma',1) for 'normal')
%
% Output
%   y        : numeric array  – same size as x, PDF values
% 
% Example:
%   y = simstudy.distributions.pdf("sqrtet", x, theta);

arguments
    model
    x                         {mustBeNumeric}
    theta struct = struct()   
end

funcName = "simstudy.distributions.pdf_" + model;

if isempty(which(funcName))
    error("simstudy:cdf", "Unknown distribution %s", model);
end

y = feval(funcName, x, theta);
end