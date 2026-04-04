function val = slscCore(obs, fitRes, space)
%SLSCCORE Shared implementation for SLSC variants.

arguments
    obs {mustBeNumeric, mustBeVector}
    fitRes struct
    space string {mustBeMember(space, ["s","x"])} = "s"
end

Q = 0.01;
ALPHA = 0.4;
BETA = 0.2;

obs = obs(:);
N = numel(obs);
pp = simstudy.util.plottingPosition(N, ALPHA, BETA);
x = sort(obs);
xStar = simstudy.distributions.icdf(fitRes.model, pp, fitRes.theta);

switch space
    case "s"
        f = simstudy.metrics.slscTransform(fitRes.model, fitRes.theta);
        z = f(x);
        zStar = f(xStar);
        qLo = simstudy.distributions.icdf(fitRes.model, Q, fitRes.theta);
        qHi = simstudy.distributions.icdf(fitRes.model, 1-Q, fitRes.theta);
        scale = abs(f(qHi) - f(qLo));
    case "x"
        z = x;
        zStar = xStar;
        qLo = simstudy.distributions.icdf(fitRes.model, Q, fitRes.theta);
        qHi = simstudy.distributions.icdf(fitRes.model, 1-Q, fitRes.theta);
        scale = abs(qHi - qLo);
end

if scale <= 0 || ~isfinite(scale)
    error("simstudy:SLSC:InvalidScale", ...
        "Normalisation scale must be finite and positive for model %s.", fitRes.model);
end

val = sqrt(mean((z - zStar).^2)) / scale;
end
