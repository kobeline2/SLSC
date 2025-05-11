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
theta = struct('a',5.2484,'b',-0.5647);
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
obs = readmatrix("~/Dropbox/git/2024_slsc/res/kyoto/data/kyoto_max.xlsx"); obs = obs(:, 2);
model = 'normal';
model = 'gumbel';      init = struct('alpha',100,'beta',30);
model = 'gev';         init = struct('k',0.1, 'sigma',30 , 'mu',100);
model = 'lnormal';
model = 'exponential';
model = 'sqrtet';
model = 'lgamma';      init = struct('a',10,'b',10,'c',-1);
fitRes = simstudy.estimators.MLE(model, obs, init);
aicVal = simstudy.metrics.score("AIC", obs, fitRes);
ceVal  = simstudy.metrics.score("Xentropy", obs, fitRes);
slscVal   = simstudy.metrics.score("SLSC", obs, fitRes);