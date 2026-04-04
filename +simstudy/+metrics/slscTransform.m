function f = slscTransform(model, theta)
%SLSCTRANSFORM Model-specific transform used by the current S-space SLSC.
%
% The current SLSC implementation follows the reduced-variate idea used on
% probability paper. For some families this is a simple linear standardisation,
% while for others it is a nonlinear transform implied by the CDF.

model = lower(string(model));

switch model
    case "normal"
        f = @(x) (x - theta.mu) ./ theta.sigma;
    case "gumbel"
        f = @(x) (x - theta.alpha) ./ theta.beta;
    case "gev"
        f = @(x) localGEVReducedVariate(x, theta);
    case "exponential"
        f = @(x) (x - theta.c) ./ theta.mu;
    case "lnormal"
        f = @(x) (log(x - theta.c) - theta.mu) ./ theta.sigma;
    case "lgamma"
        f = @(x) (x - theta.c) ./ theta.a;
    case "sqrtet"
        f = @(x) localSqrtETReducedVariate(x, theta);
    otherwise
        error("simstudy:SLSC:UnknownModel", ...
            "No SLSC transform is defined for model %s.", model);
end
end

function u = localGEVReducedVariate(x, theta)
z = (x - theta.mu) ./ theta.sigma;

if abs(theta.k) < 1e-10
    u = z;
else
    u = log(1 + theta.k .* z) ./ theta.k;
end
end

function u = localSqrtETReducedVariate(x, theta)
t = sqrt(theta.b .* x);
u = t - log(theta.a) - log1p(t);
end
