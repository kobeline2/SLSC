function plotGrid(root)
%PLOTGRID  Draw N–metric curves from aggregate.mat files produced by runBatch.
%
%   plotGrid("results")          % default location
%
%   • 自動で directory walk し，タグ名から N / gen / fit を抽出
%   • aggregate.mat 内の すべての metrics.* を描画
%   • 横軸 N，縦軸 metric，凡例は "gen→fit"
%
% ---------------------------------------------------------

if nargin==0, root = "results"; end

% ---------- collect .mat paths ---------------------------------------
files = dir(fullfile(root,"**","aggregate.mat"));
if isempty(files); error("No aggregate.mat found under %s",root); end

% ---------- parse tags & gather meta ---------------------------------
TABLE = [];
for k = 1:numel(files)
    folder = files(k).folder;
    tag    = erase(folder, root + filesep);            % e.g. "N50_gumbel2gev"

    % parse with regexp: N(\d+)_([a-z]+)2([a-z]+)
    tok = regexp(tag,'N(\d+)_([^0-9]+)2(.+)','tokens','once');
    if isempty(tok), continue; end

    N   = str2double(tok{1});
    gen = string(tok{2}); fit = string(tok{3});

    s   = load(fullfile(folder,"aggregate.mat"),"allMetrics");
    metrics = s.allMetrics;
    mNames  = fieldnames(metrics);

    for m = 1:numel(mNames)
        TABLE = [TABLE;                             %#ok<AGROW>
            table(N,gen,fit,string(mNames{m}), ...
                  mean(metrics.(mNames{m})), ...
                  'VariableNames',{'N','gen','fit','metric','value'})];
    end
end

if isempty(TABLE); error("No metrics loaded."); end

% ---------- plot ------------------------------------------------------
metricsSet = unique(TABLE.metric);
clr = lines(numel(unique(TABLE.fit))); % colormap

figure('Position',[100 100 1200 400]);
for mi = 1:numel(metricsSet)
    subplot(1,numel(metricsSet),mi); hold on
    thisMetric = metricsSet(mi);

    % loop over gen→fit pairs
    pairs = unique(TABLE(:,{'gen','fit'}),'rows');
    for pi = 1:height(pairs)
        g = pairs.gen(pi); f = pairs.fit(pi);
        idx = TABLE.gen==g & TABLE.fit==f & TABLE.metric==thisMetric;
        subT = TABLE(idx, :);
        plot(subT.N, subT.value, '-o', ...
             'Color', clr(find(unique(TABLE.fit)==f,1), :), ...
             'DisplayName', g + "→" + f);
    end
    title(thisMetric); xlabel('N'); ylabel(thisMetric);
    grid on
    if mi==numel(metricsSet)
        legend('Location','bestoutside');
    end
end
end