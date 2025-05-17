%% def theta
model = 'normal';
theta = struct('mu',0,'sigma',1);
model = 'gumbel';   
theta = struct('alpha',97.7438,'beta',30.7042);
model = 'gev';
theta = struct('k',0.0910, 'sigma',29.5452 , 'mu',96.2345);
model = 'lnormal';
theta = struct('c',31.3965, 'mu',4.3254 , 'sigma',0.4837);
model = 'exponential';
theta = struct('c',54.4999,'mu',61.6321);
model = 'sqrtet';
theta = struct('a',190.2683,'b',0.5685);
model = 'lgamma';
theta = struct('a',26.7121,'b',2.4696,'c',50.1637);

%% rand_
N = 10000;
r = simstudy.distributions.rnd(model, N, theta);
histogram(r)

%% cdf
x = 0:1:300;
y = simstudy.distributions.cdf(model, x, theta);
plot(x, y)

%% pdf
x = 0:1:300;
y = simstudy.distributions.pdf(model, x, theta);
plot(x, y)

%% loglike
data = [100, 200, 300];
ll = simstudy.distributions.loglike(model, data, theta);

%% icdf
u = [0.1, 0.5, 0.9];
x = simstudy.distributions.icdf(model, u, theta);

%% MLE+score
% 京都の雨量をよむ
obs = readmatrix("data/kyoto/kyoto_max.xlsx"); obs = obs(:, 2);
model = 'normal';
model = 'gumbel';      theta0 = struct('alpha',100,'beta',30);
model = 'gev';         theta0 = struct('k',0.1, 'sigma',30 , 'mu',100);
model = 'lnormal';     theta0 = struct('c',30, 'mu',5 , 'sigma',1);
model = 'exponential'; theta0 = struct('c',50,'mu',50);
model = 'sqrtet';      theta0 = struct('a',120,'b',0.5);
model = 'lgamma';      theta0 = struct('a',20,'b',2,'c',50);
% fitした結果のPDFをヒストグラムに重ねる
fitRes = simstudy.estimators.MLE(model, obs, theta0);
x = 0:1:1000; y = simstudy.distributions.pdf(model, x, fitRes.theta);
histogram(obs); yyaxis right; plot(x, y)
% metricsの計算
aicVal = simstudy.metrics.score("AIC", obs, fitRes);
ceVal  = simstudy.metrics.score("Xentropy", obs, fitRes);
slscVal   = simstudy.metrics.score("SLSC", obs, fitRes);