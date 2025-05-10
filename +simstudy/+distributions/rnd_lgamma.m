function x = rnd_lgamma(theta, N)
% 1.	Pearson, K. (1916) “Skew Variation…”, Biometrika.
% 2.	USGS Bulletin 17C (2018) ― 年最大洪水の確率推定.
% 3.	H. Stedinger, R. Vogel. Hydrologic Frequency Analysis (1993).
% 4.	M. Castillo-Garsow et al. “Fitting Pearson Type III…”, J. Hydrol. (2020).

u  = rand(N,1);
y  = gaminv(u, theta.b, 1);        % Gamma(k,1)
x  = theta.c + theta.a * y;        % Pearson III
end