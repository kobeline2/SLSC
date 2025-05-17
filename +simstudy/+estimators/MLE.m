function fitRes = MLE(model, obs, theta0)
%MLE  Hybrid maximum-likelihood estimator.
%
%   • Built-in fitter exists → delegate (normfit, gevfit, …)
%   • Otherwise fall back to fminunc on −loglik
%
%   Inputs:
%       model : distribution ID (string)
%       obs   : sample vector
%       theta0: struct | numeric (initial guess, only for fallback)
%
%   Output:
%       fitRes : struct (fields: model, theta, loglik, exitflag, output)

model = lower(string(model));

switch model
%----------------------------------------------------------------------
% Built-in paths
%----------------------------------------------------------------------
case "norm"              % Normal(mu,sigma)
    [muHat,sigmaHat] = normfit(obs);
    theta = struct('mu',muHat,'sigma',sigmaHat);
    ll    = sum(log(normpdf(obs,muHat,sigmaHat)));
    fitRes = packResult(model,theta,ll,1,struct("Method","normfit"));
case "gumbel"
    thetaHat = evfit(-obs);
    theta = struct('alpha',-thetaHat(1),'beta',thetaHat(2));
    ll    = sum(log(evpdf(-obs,thetaHat(1),thetaHat(2))));
    fitRes = packResult(model,theta,ll,1,struct("Method","evfit_modified"));

case "gev"               % Generalized Extreme Value(k,sigma,mu)
    thetaHat = gevfit(obs);
    theta = struct('k',thetaHat(1),'sigma',thetaHat(2),'mu',thetaHat(3));
    ll    = sum(log(gevpdf(obs,thetaHat(1),thetaHat(2),thetaHat(3))));
    fitRes = packResult(model,theta,ll,1,struct("Method","gevfit"));
case "exponential"
    theta = mle_shiftexp(obs);
    ll = -length(obs)*log(theta.mu) - sum((obs - theta.c)./theta.mu);
    fitRes = packResult(model,theta,ll,1,struct("Method","mle_shiftexp"));
%----------------------------------------------------------------------
% Fallback: fminunc + loglike dispatcher
%----------------------------------------------------------------------
case "lgamma" % special treatment to satisfy theta.c < min(obs)
    fitRes = MLE_lgamma(obs, theta0);
otherwise
    %―― ① pack / unpack と p0 を取得 ―――――――――――――――――――
    [pack, unpack, p0] = simstudy.util.makeTransform(model, theta0);
    
    %―― ② 目的関数 (内部空間) ―――――――――――――――――――――――――――
    nll   = @(p) -simstudy.distributions.loglike(model, obs, unpack(p));
    safeN = @(p) localSafeNLL(nll, p);
    
    %―― ③ 最適化 ――――――――――――――――――――――――――――――――――
    opts  = optimoptions('fminunc', ...
              'Display','off','Algorithm','quasi-newton','MaxIterations',1e4);
    [pHat,fval,exitflag,out] = fminunc(safeN, p0, opts);
    
    %―― ④ 逆変換して保存 ―――――――――――――――――――――――――――――
    theta = unpack(pHat);          % ⇐ ここで a,b>0 保証
    ll    = -fval;
    fitRes = packResult(model, theta, ll, exitflag, out);
end
end
% ---
function val = localSafeNLL(fun, p)
    v = fun(p);
    if ~isfinite(v)
        val = 1e6;               % realmax → 1e6 に縮小
    else
        val = v;
    end
end
%======================================================================
function fitRes = packResult(model,theta,ll,flag,out)
fitRes.model    = model;
fitRes.theta    = theta;
fitRes.loglik   = ll;
fitRes.exitflag = flag;
fitRes.output   = out;
end
%======================================================================
function theta = mle_shiftexp(x)
cHat   = min(x);
muHat  = mean(x) - cHat;
theta  = struct('c', cHat, 'mu', muHat);
end

function fitRes = MLE_lgamma(obs, initStruct)
% initStruct : struct('a',a0,'b',b0,'c',c0)

% ---- convert struct -> numeric vector -------------------------------
init = [initStruct.a, initStruct.b, initStruct.c];   % 1×3 double

% ---- bounds ---------------------------------------------------------
ymin = min(obs);
lb = [1e-6, 1e-6, -Inf];           % lower bounds (double)
ub = [ Inf , Inf , ymin - eps];    % upper bounds (double)

% ---- negative log-likelihood ---------------------------------------
nll = @(p) -simstudy.distributions.loglike("lgamma", ...
          obs, struct('a',p(1),'b',p(2),'c',p(3)));

% ---- optimizer options ---------------------------------------------
opts = optimoptions('fmincon',...
        'Display','off',...
        'Algorithm','interior-point');

% ---- run optimization ----------------------------------------------
[pHat,fval,exitflag,out] = fmincon(nll, init, [],[],[],[], lb, ub, [], opts);

% ---- package results -----------------------------------------------
thetaHat = struct('a',pHat(1), 'b',pHat(2), 'c',pHat(3));
fitRes   = struct( ...
    'model'   ,"lgamma", ...
    'theta'   ,thetaHat, ...
    'loglik'  ,-fval, ...
    'exitflag', exitflag, ...
    'output'  , out );
end