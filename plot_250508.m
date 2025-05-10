root = "~/Dropbox/git/SLSC/results/";
files = dir(fullfile(root,"**","aggregate.mat"));
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

    % -------- フィールド名を作成 -----------------------------------------
    pairFld = matlab.lang.makeValidName(gen + "2" + fit);   % "lgamma2exponential"
    nFld    = matlab.lang.makeValidName("N" + N);           % "N50"
    % -------- 構造体へ保存 (初回なら res を用意) -------------------------
    if ~exist("res","var"), res = struct(); end
    if ~isfield(res, pairFld), res.(pairFld) = struct(); end  
    res.(pairFld).(nFld) = metrics.slsc;       % ← ここに格納


    mNames  = fieldnames(metrics);
    if strcmp(gen, fit)
        for m = 1:1
            TABLE = [TABLE;                             %#ok<AGROW>
                table(N,gen,fit,string(mNames{m}), ...
                      quantile(metrics.(mNames{m}), 0.80), ...
                      'VariableNames',{'N','gen','fit','metric','value'})];
        end
    end
end


%%
genList = ["lgamma", "sqrtet", "gumbel", "gev", "lnormal"]; 
fitList = ["lgamma", "sqrtet", "gumbel", "gev", "lnormal"];
Nvals  = [50 100 150];
Nvalnames = ["N50", "N100", "N150"];
for gen = genList
for fit = fitList
    fld = gen+"2"+fit;
    d = res.(fld);
    
    figure; hold on;
    for i = 1:numel(Nvals)
        xJitter = Nvals(i) + 0.8*(rand(size(d.(Nvalnames(i))))-0.5);  % jitter ±0.4
        scatter(xJitter, d.(Nvalnames(i)), 8, 'filled', ...
                'MarkerFaceAlpha', 0.07, 'MarkerEdgeAlpha', 0.07);
        
        q95 = quantile(d.(Nvalnames(i)), 0.95);
        q05 = quantile(d.(Nvalnames(i)), 0.05);
        plot(Nvals(i), q95, 'ro', 'MarkerSize',8, 'LineWidth',1.8, 'MarkerFaceColor','w');
        plot(Nvals(i), q05, 'ro', 'MarkerSize',8, 'LineWidth',1.8, 'MarkerFaceColor','w');
        % 3) 平均値をマーカーで表示（青）
        m   = mean(d.(Nvalnames(i)));
        plot(Nvals(i), m, 'bo', 'MarkerSize', 8, 'LineWidth', 1.5, ...
             'MarkerFaceColor','w');            % 白抜き青丸
    end
    xlabel('N'); ylabel('SLSC');
    set(gca,'XTick',Nvals);
    grid on; box on;
    xlim([25 175])
    tmp = ylim; ylim([0, tmp(2)]);
    ax = gca;
    text(ax, 0.5, 0.95, fld, ...              % (x,y) = (0.5,0.95) → 上部中央
         'Units','normalized', ...            % 0〜1 の正規化座標
         'HorizontalAlignment','center', ...
         'VerticalAlignment','top', ...
         'FontSize',12);
    fig = gcf;
    setFig(fig, 7, 7, 9, 'T')
    print(fig, "fig/slsc_"+fld+".png", '-dpng', '-r600')
    close all;
        

end
end

%%

