%% probpaper_linear_weights_ln3_clean.m
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
p   = (i - 0.4) ./ (N + 0.2);   % Cunnane
pex = 1 - p;                    % exceedance probability
z   = norminv(p);

%% theoretical values
s_true = z;
x_true = c + exp(muL + sigmaL .* s_true);

%% sample deviations in S-space
% Make deviations intentionally larger for explanatory figure
ds = [ 0.10; -0.08; 0.12; 0.32; -0.10; 0.08; -0.07; 0.10; -0.12; 0.15; -0.10; 0.32 ];

s_obs = s_true + ds;
x_obs = c + exp(muL + sigmaL .* s_obs);

% highlighted points: same Delta s, but very different Delta x
idxA = 4;    % moderate rainfall side
idxB = 12;   % high rainfall side

%% smooth curves
pGrid   = linspace(0.01, 0.99, 500);
pexGrid = 1 - pGrid;
zGrid   = norminv(pGrid);
sGrid   = zGrid;
xGrid   = c + exp(muL + sigmaL .* sGrid);

%% theoretical weight function
wGrid = 1 ./ (sigmaL * (xGrid - c));

%% exact effective weights by logarithmic mean
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
w_eff  = 1 ./ (sigmaL * L);

%% figure
figure('Position',[80 80 1200 460]);

%% ---------------- left panel ----------------
subplot(2,1,1); hold on; box on;

% horizontal residuals in S-space
for k = 1:N
    plot([s_true(k), s_obs(k)], [z(k), z(k)], '-', ...
        'Color', 'r', 'LineWidth', 0.9);
end
% theoretical straight line
plot(sGrid, zGrid, 'k-', 'LineWidth', 1.8);
% sample points
plot(s_obs, z, 'ko', 'MarkerFaceColor', [0.20 0.50 0.90], 'MarkerSize', 4);

% % highlighted points
% plot(s_obs(idxA), z(idxA), 'ro', 'MarkerSize', 7.5, 'LineWidth', 1.4);
% plot(s_obs(idxB), z(idxB), 'ro', 'MarkerSize', 7.5, 'LineWidth', 1.4);
% 
% text(max(s_obs(idxA),s_obs(idxB))+0.08, mean([z(idxA), z(idxB)]), ...
%     'same \Delta s', 'FontSize', 10, 'Color', 'r');

% title('Probability-paper coordinates');
% grid on;

% x-axis shown as rainfall x
xTickVals = [60 80 100 150 200 300];
sTicks = (log(xTickVals - c) - muL) ./ sigmaL;
set(gca, 'XTick', sTicks, 'XTickLabel', string(xTickVals));
xlabel('Rainfall, x');

% y-axis shown as exceedance probability
pexTicks = [0.99 0.95 0.80 0.50 0.20 0.05 0.01];
zTicks = norminv(1 - pexTicks);
set(gca, 'YTick', zTicks, 'YTickLabel', compose('%.2f', pexTicks));
ylabel('Exceedance probability');

%% ---------------- right panel ----------------
subplot(2,1,2); hold on; box on;

yyaxis left

for k = 1:N
    plot([x_true(k), x_obs(k)], [pex(k), pex(k)], '-', ...
        'Color', 'r', 'LineWidth', 0.9);
end
plot(xGrid, pexGrid, 'k-', 'LineWidth', 1.8);
plot(x_obs, pex, 'ko', 'MarkerFaceColor', [0.20 0.50 0.90],...
    'MarkerSize', 4);

% plot(x_obs(idxA), pex(idxA), 'ro', 'MarkerSize', 7.5, 'LineWidth', 1.4);
% plot(x_obs(idxB), pex(idxB), 'ro', 'MarkerSize', 7.5, 'LineWidth', 1.4);

dxA = abs(x_obs(idxA) - x_true(idxA));
dxB = abs(x_obs(idxB) - x_true(idxB));

% text(x_obs(idxA)+4, pex(idxA)+0.025, sprintf('\\Delta x = %.1f', dxA), ...
%     'FontSize', 9.5, 'Color', 'r');
% text(x_obs(idxB)-42, pex(idxB)+0.025, sprintf('\\Delta x = %.1f', dxB), ...
%     'FontSize', 9.5, 'Color', 'r');
% 
% text(mean([x_obs(idxA), x_obs(idxB)]), mean([pex(idxA), pex(idxB)])-0.08, ...
%     'different \Delta x', 'FontSize', 10, 'Color', 'r');

xlabel('Rainfall, x');
ylabel('Exceedance probability');
% title('Linear coordinates');
% grid on;
ax = gca; ax.YColor = 'k';

yyaxis right
plot(xGrid, wGrid, '-', 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.6);
stem(xi_eff, w_eff, 'Color', 'k', ...
    'LineWidth', 0.9, 'Marker', 'none');
ylabel('Weight, w(x)');
ax = gca; ax.YColor = 'k';

legend({'theoretical curve','sample points','\Delta x','', ...
        'theoretical weight','effective weights'}, ...
       'Location','northeast', 'FontSize', 8);

%% overall title
sgtitle('Same deviation in S-space, different deviation in X-space', ...
    'FontSize', 13, 'FontWeight', 'bold');

%% save
outFile = fullfile(outDir, 'probpaper_linear_weights_ln3_clean.pdf');
print(gcf, outFile, '-dpdf', '-bestfit');

disp(['saved: ' outFile]);