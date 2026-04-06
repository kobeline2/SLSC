function [f, info] = slscTransform(model, theta, opts)
%SLSCTRANSFORM Model-specific transform used by the S-space SLSC.
%
%   f = simstudy.metrics.slscTransform(model, theta)
%   f = simstudy.metrics.slscTransform(model, theta, Profile="eva_reduced")
%   [f, info] = simstudy.metrics.slscTransform(...)
%
% The current default profile is "japan_admin", which follows the
% linearised transforms commonly used in Japanese administrative practice
% for GEV and sqrt-ET. Alternative reduced-variate formulas can be selected
% through the profile or by a direct model-specific variant override.

arguments
    model
    theta struct
    opts.Profile string = "japan_admin"
    opts.Variant string = ""
end

model = lower(string(model));
profile = lower(string(opts.Profile));
variant = localResolveVariant(model, profile, opts.Variant);

switch model
    case "normal"
        f = @(x) (x - theta.mu) ./ theta.sigma;
        label = "(x - mu) / sigma";
    case "gumbel"
        f = @(x) (x - theta.alpha) ./ theta.beta;
        label = "(x - alpha) / beta";
    case "gev"
        switch variant
            case "linear"
                f = @(x) (x - theta.mu) ./ theta.sigma;
                label = "(x - mu) / sigma";
            case "gev_reduced"
                f = @(x) localGEVReducedVariate(x, theta);
                label = "log(1 + k*z) / k";
            otherwise
                error("simstudy:SLSC:UnknownVariant", ...
                    "Unknown GEV SLSC transform variant %s.", variant);
        end
    case "exponential"
        f = @(x) (x - theta.c) ./ theta.mu;
        label = "(x - c) / mu";
    case "lnormal"
        f = @(x) (log(x - theta.c) - theta.mu) ./ theta.sigma;
        label = "(log(x - c) - mu) / sigma";
    case "lgamma"
        f = @(x) (x - theta.c) ./ theta.a;
        label = "(x - c) / a";
    case "sqrtet"
        switch variant
            case "bx"
                f = @(x) theta.b .* x;
                label = "b * x";
            case "sqrtet_reduced"
                f = @(x) localSqrtETReducedVariate(x, theta);
                label = "sqrt(b*x) - log(a) - log1p(sqrt(b*x))";
            otherwise
                error("simstudy:SLSC:UnknownVariant", ...
                    "Unknown sqrt-ET SLSC transform variant %s.", variant);
        end
    otherwise
        error("simstudy:SLSC:UnknownModel", ...
            "No SLSC transform is defined for model %s.", model);
end

info = struct("model", model, "profile", profile, "variant", variant, "label", label);
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

function variant = localResolveVariant(model, profile, variantInput)
variant = lower(string(variantInput));

if strlength(variant) == 0
    switch model
        case "gev"
            switch profile
                case {"japan_admin", "japan", "jp_admin"}
                    variant = "linear";
                case {"eva_reduced", "reduced", "legacy", "cdf_reduced"}
                    variant = "gev_reduced";
                otherwise
                    error("simstudy:SLSC:UnknownProfile", ...
                        "Unknown SLSC profile %s for model %s.", profile, model);
            end
        case "sqrtet"
            switch profile
                case {"japan_admin", "japan", "jp_admin"}
                    variant = "bx";
                case {"eva_reduced", "reduced", "legacy", "cdf_reduced"}
                    variant = "sqrtet_reduced";
                otherwise
                    error("simstudy:SLSC:UnknownProfile", ...
                        "Unknown SLSC profile %s for model %s.", profile, model);
            end
        case "normal"
            variant = "location_scale";
        case "gumbel"
            variant = "location_scale";
        case "exponential"
            variant = "shift_scale";
        case "lnormal"
            variant = "log_shift_scale";
        case "lgamma"
            variant = "shift_scale";
        otherwise
            error("simstudy:SLSC:UnknownModel", ...
                "No SLSC transform is defined for model %s.", model);
    end
    return;
end

switch model
    case "gev"
        switch variant
            case {"linear", "japan_linear", "location_scale"}
                variant = "linear";
            case {"gev_reduced", "reduced", "cdf_reduced"}
                variant = "gev_reduced";
            otherwise
                error("simstudy:SLSC:UnknownVariant", ...
                    "Unknown GEV SLSC transform variant %s.", variant);
        end
    case "sqrtet"
        switch variant
            case {"bx", "linear_bx", "japan_bx"}
                variant = "bx";
            case {"sqrtet_reduced", "reduced", "cdf_reduced"}
                variant = "sqrtet_reduced";
            otherwise
                error("simstudy:SLSC:UnknownVariant", ...
                    "Unknown sqrt-ET SLSC transform variant %s.", variant);
        end
    case "normal"
        variant = "location_scale";
    case "gumbel"
        variant = "location_scale";
    case "exponential"
        variant = "shift_scale";
    case "lnormal"
        variant = "log_shift_scale";
    case "lgamma"
        variant = "shift_scale";
    otherwise
        error("simstudy:SLSC:UnknownModel", ...
            "No SLSC transform is defined for model %s.", model);
end
end
