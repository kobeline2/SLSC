%% make_figure1_concept.m
clear; close all; clc;

%% output
outDir = '/Users/takahiro/Documents/git/SLSC/paper/jsce/fig/method';
if ~exist(outDir,'dir')
    mkdir(outDir);
end

%% parameters
N      = 12;
c      = 50;
muL    = 4.30;
sigmaL = 0.35;

%% plotting positions
i   = (1:N)';
p   = (i - 0.4) ./ (N + 0.2);   % Cunnane plotting position
z   = norminv(p);               % probability-paper coordinate

%% theoretical values
s_true = z;
x_true = c + exp(muL + sigmaL .* s_true);

%% sample deviations in S-space
% Deviations are intentionally exaggerated for an explanatory figure.
ds = [ 0.10; -0.08; 0.12; 0.32; -0.10; 0.08; ...
      -0.07; 0.10; -0.12; 0.15; -0.10; 0.32 ];

s_obs = s_true + ds;
x_obs = c + exp(muL + sigmaL .* s_obs);

% highlighted points: similar Delta s, different Delta x
idxA = 4;
idxB = 12;

%% smooth curves
pGrid   = linspace(0.01, 0.99, 500);
zGrid   = norminv(pGrid);
sGrid   = zGrid;
xGrid   = c + exp(muL + sigmaL .* sGrid);

%% squared weight function for S-space squared error
fprimeGrid = 1 ./ (sigmaL * (xGrid - c));

%% exact effective weights via logarithmic mean
a = x_obs  - c;
b = x_true - c;

L = zeros(N,1);
for k = 1:N
    if abs(a(k) - b(k)) < 1e-12
        L(k) = a(k);
    else
        L(k) = (a(k) - b(k)) / (log(a(k)) - log(b(k)));
    end
end

xi_eff = c + L;
fprime_eff  = 1 ./ (sigmaL * L);

% Normalise the squared effective weights so their sum is one.
weightDenom = sum(fprime_eff .^ 2);
omegaGrid = (fprimeGrid .^ 2) ./ weightDenom;
omega_eff  = (fprime_eff .^ 2) ./ weightDenom;

%% common settings
cumTicks = [0.05 0.20 0.50 0.80 0.95];
zTicks   = norminv(cumTicks);
zLim     = [norminv(0.02), norminv(0.98)];

xLimRain = [75, 225];

%% figure
fig = figure('Position',[80 80 720 760]);
clf;

% Manual axes layout: [left bottom width height]
ax1 = axes('Position',[0.12 0.71 0.80 0.27]); hold(ax1,'on'); box(ax1,'on');
ax2 = axes('Position',[0.12 0.35 0.80 0.27]); hold(ax2,'on'); box(ax2,'on');
ax3 = axes('Position',[0.12 0.12 0.80 0.13]); hold(ax3,'on'); box(ax3,'on');

%% ---------------- panel (a): probability-paper coordinates ----------------
axes(ax1);

% deviations in S-space
for k = 1:N
    plot([s_true(k), s_obs(k)], [z(k), z(k)], '-', ...
        'Color', 'r', 'LineWidth', 0.9);
end

% theoretical line and sample points
plot(sGrid, zGrid, 'k-', 'LineWidth', 1.6);
plot(s_obs, z, 'ko', 'MarkerFaceColor', [0.20 0.50 0.90], 'MarkerSize', 4);

% % highlighted points
% plot(s_obs([idxA idxB]), z([idxA idxB]), 'ro', ...
%     'MarkerSize', 6.5, 'LineWidth', 1.2);

xlim([-2.2 2.2]);
ylim(zLim);

set(gca, 'YTick', zTicks, 'YTickLabel', compose('%.2f', cumTicks));
set(gca, 'XTick', -2:1:2);

xlabel('Standardised variate, s');
ylabel('Cumulative probability');
% title('(a) Probability-paper coordinates', 'FontWeight','normal');

%% ---------------- panel (b): linear rainfall coordinate ----------------
axes(ax2);

% deviations in X-space
for k = 1:N
    plot([x_true(k), x_obs(k)], [z(k), z(k)], '-', ...
        'Color', 'r', 'LineWidth', 0.9);
end

% theoretical curve and sample points
plot(xGrid, zGrid, 'k-', 'LineWidth', 1.6);
plot(x_obs, z, 'ko', 'MarkerFaceColor', [0.20 0.50 0.90], 'MarkerSize', 4);

% % highlighted points
% plot(x_obs([idxA idxB]), z([idxA idxB]), 'ro', ...
%     'MarkerSize', 6.5, 'LineWidth', 1.2);

xlim(xLimRain);
ylim(zLim);

set(gca, 'YTick', zTicks, 'YTickLabel', compose('%.2f', cumTicks));
set(gca, 'XTick', 80:20:220);

xlabel('Rainfall, x');
ylabel('Cumulative probability');
% title('(b) Linear rainfall coordinate', 'FontWeight','normal');

%% ---------------- panel (c): weights ----------------
axes(ax3);

plot(xGrid, omegaGrid, '-', 'Color', [0.8500, 0.3250, 0.0980], ...
    'LineWidth', 1.5);
hold on;

stem(xi_eff, omega_eff, 'Color', 'k', ...
    'LineWidth', 0.8, 'Marker', 'none');

% % highlighted effective weights
% plot(xi_eff([idxA idxB]), w_eff([idxA idxB]), 'ro', ...
%     'MarkerFaceColor','none', 'MarkerSize', 6.5, 'LineWidth', 1.2);

xlim(xLimRain);

wMax = max([omegaGrid(:); omega_eff(:)]);
ylim([0, 1.10*wMax]);

xlabel('Rainfall, x');
ylabel('Normalized squared weight');
% title('(c) Position-dependent weights', 'FontWeight','normal');

legend({'normalized \{f''(x)\}^2', 'normalized effective weights'}, ...
    'Location','northeast', 'FontSize', 8);

%% final style
set(findall(fig, '-property', 'FontName'), 'FontName', 'Helvetica');
set(findall(fig, '-property', 'FontSize'), 'FontSize', 9);
set(findall(fig, '-property', 'LineWidth'), 'LineWidth', 0.9);

% If setFig is available in your environment, keep it.
% Otherwise, comment this line out.
if exist('setFig','file') == 2
    setFig(fig, 12, 16, 9, 'Helvetica');
end

%% save
outFile = fullfile(outDir, 'probpaper_linear_weights_ln3_3panel.pdf');
exportgraphics(fig, outFile, 'ContentType', 'vector');

disp(['saved: ' outFile]);
