function [pack, unpack, p0] = makeTransform(model, theta0)
meta = simstudy.config.paramMeta(model);

% ---- pack: θ → η -----------------------------------
pack = @(th) arrayfun(@(k) toInternal(th.(meta(k).name), meta(k).domain), ...
                      1:numel(meta));

% ---- unpack: η → θ ---------------------------------
unpack = @(p) cell2struct( ...
                arrayfun(@(k) fromInternal(p(k), meta(k).domain), ...
                         1:numel(meta), 'UniformOutput',false), ...
                {meta.name}, 2 );

% ---- convert initial guess --------------------------
p0 = pack(theta0);
end

% -------- helpers ------------------------------------
function y = toInternal(x, dom)
    switch dom
        case "pos",  y = log(x);
        case "neg",  y = log(-x);
        case "unit", y = log(x./(1-x));   % logit
        otherwise,   y = x;               % "real" など
    end
end
function x = fromInternal(y, dom)
    switch dom
        case "pos",  x = exp(y);
        case "neg",  x = -exp(y);
        case "unit", x = 1./(1+exp(-y));
        otherwise,   x = y;
    end
end