function r = rnd_sqrtet(theta, N)
% theta: struct('a', a, 'b', b)

arguments
    theta struct
    N      (1,1) {mustBeInteger, mustBePositive}
end

if ~isfield(theta,'a') || ~isfield(theta,'b')
    error("rnd_sqrtet:params","theta.a and theta.b are needed.");
end

% inversion method
a = simstudy.distributions.cdf_sqrtet(theta, 0);
u = a + (1-a).*rand(N,1);
r = simstudy.distributions.icdf_sqrtet(theta, u); 
end