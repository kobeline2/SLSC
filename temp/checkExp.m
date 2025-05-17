gen = 'exponential';
theta = struct('c',54.4999,'mu',61.6321);
N = 1000;
obs = simstudy.distributions.rnd(gen, N, theta);
histogram(obs, BinWidth=5);
% fit = "gumbel"; theta0 = struct('alpha',100,'beta',30);
fit = "gev";    theta0 = struct('k',0.0910, 'sigma',29.5452 , 'mu',96.2345);
fitRes = simstudy.estimators.MLE(fit, obs, theta0);
x = -200:1:400; 
y = simstudy.distributions.pdf(fit, x, fitRes.theta);
yyaxis right; plot(x, y)

%%
% gen = 'normal';      theta = struct('mu',116.1320,'sigma',42.5230);
% gen = 'gumbel';      theta = struct('alpha',97.7438,'beta',30.7042);
% gen = 'gev';         theta = struct('k',0.0910, 'sigma',29.5452 , 'mu',96.2345);
% gen = 'lnormal';     theta = struct('c',31.3965, 'mu',4.3254 , 'sigma',0.4837);
gen = 'exponential'; theta = struct('c',54.4999,'mu',61.6321);
% gen = 'sqrtet';      theta = struct('a',190.2683,'b',0.5685);
% gen = 'lgamma';      theta = struct('a',26.7121,'b',2.4696,'c',50.1637);

N = 1000;
obs = simstudy.distributions.rnd(gen, N, theta);
% fit = "gumbel"; theta0 = struct('alpha',100,'beta',30);
fit = "gev";    theta0 = struct('k',0.0910, 'sigma',29.5452 , 'mu',96.2345);
fitRes.theta
fitRes = simstudy.estimators.MLE(fit, obs, theta0);
slscVal   = simstudy.metrics.score("SLSC", obs, fitRes);
%%
pp    = simstudy.util.plottingPosition(N, 0.4, 0.2);
x     = sort(obs);
xStar = simstudy.distributions.icdf(fitRes.model, pp, fitRes.theta);

scatter(x, xStar); 
axis equal

%%
for gen = ["lgamma", "sqrtet", "gumbel","gev","lnormal","exponential"]
    
    k = [res.(gen+"2gev").N100.theta.k]';
    histogram(k); hold on
end