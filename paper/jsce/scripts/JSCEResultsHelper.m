classdef JSCEResultsHelper
    methods(Static)
        function opts = defaultOptions()
            init();

            opts = struct();
            opts.models = JSCEResultsHelper.modelList();
            opts.Nlist = [50, 100, 150];
            opts.rep = 100;
            opts.metrics = {'SLSC', 'SLSC_X', 'AIC'};
            opts.slscProfile = "japan_admin";
            opts.runLabelPrefix = "paper_jsce";
            opts.summaryFilename = "results_summary.mat";
            opts.scalingFigureFilename = "slsc_n_scaling_panels.pdf";
            opts.criterionFigureFilename = "criterion_compare.pdf";
            opts.makeFigures = true;
        end

        function opts = shortOptions()
            opts = JSCEResultsHelper.defaultOptions();
            opts.runLabelPrefix = "paper_jsce_short";
            opts.summaryFilename = "results_summary_short.mat";
        end

        function out = runExperiment(opts)
            init();
            opts = JSCEResultsHelper.normalizeOptions(opts);

            paths = slscLocalPaths(true);
            runLabel = opts.runLabelPrefix + "_" + ...
                string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
            runRoot = fullfile(paths.runsDir, runLabel);
            mkdir(runRoot);

            cfg = simstudy.config.base();
            cfg.genList = opts.models;
            cfg.fitList = opts.models;
            cfg.Nlist = opts.Nlist;
            cfg.rep = opts.rep;
            cfg.metrics = opts.metrics;
            cfg.slscProfile = opts.slscProfile;
            cfg.rawDirRoot = runRoot;

            fprintf("Running paper results into %s\n", runRoot);
            experiments.runBatch(cfg);

            summary = JSCEResultsHelper.buildSummary(runRoot, cfg);
            summary = JSCEResultsHelper.decorateSummary(summary);

            summaryPath = fullfile(JSCEResultsHelper.figureDir(), opts.summaryFilename);
            save(summaryPath, "summary", "cfg", "runRoot");

            fig1Path = fullfile(JSCEResultsHelper.figureDir(), opts.scalingFigureFilename);
            fig2Path = fullfile(JSCEResultsHelper.figureDir(), opts.criterionFigureFilename);
            if opts.makeFigures
                JSCEResultsHelper.makeScalingFigure(summary, fig1Path);
                JSCEResultsHelper.makeCriterionFigure(summary, fig2Path);
            end

            JSCEResultsHelper.printTablePreview(summary);
            out = JSCEResultsHelper.buildOutput(runRoot, summaryPath, fig1Path, fig2Path, summary);
        end

        function out = rebuildFromSummary(summaryPath)
            [summary, cfg, runRoot] = JSCEResultsHelper.loadSummary(summaryPath);
            summary = JSCEResultsHelper.decorateSummary(summary);
            save(summaryPath, "summary", "cfg", "runRoot");

            fig1Path = fullfile(JSCEResultsHelper.figureDir(), "slsc_n_scaling_panels.pdf");
            fig2Path = fullfile(JSCEResultsHelper.figureDir(), "criterion_compare.pdf");
            JSCEResultsHelper.makeScalingFigure(summary, fig1Path);
            JSCEResultsHelper.makeCriterionFigure(summary, fig2Path);

            JSCEResultsHelper.printTablePreview(summary);
            out = JSCEResultsHelper.buildOutput(runRoot, summaryPath, fig1Path, fig2Path, summary);
        end

        function outPath = makeScalingFigureFromSummary(summaryPath, outPath, style)
            if nargin < 2 || strlength(string(outPath)) == 0
                outPath = fullfile(JSCEResultsHelper.figureDir(), "slsc_n_scaling_panels.pdf");
            end
            if nargin < 3
                style = struct();
            end

            [summary, cfg, runRoot] = JSCEResultsHelper.loadSummary(summaryPath);
            summary = JSCEResultsHelper.decorateSummary(summary);
            save(summaryPath, "summary", "cfg", "runRoot");
            JSCEResultsHelper.makeScalingFigure(summary, outPath, style);
        end

        function outPath = makeCriterionFigureFromSummary(summaryPath, outPath, style)
            if nargin < 2 || strlength(string(outPath)) == 0
                outPath = fullfile(JSCEResultsHelper.figureDir(), "criterion_compare.pdf");
            end
            if nargin < 3
                style = struct();
            end

            [summary, cfg, runRoot] = JSCEResultsHelper.loadSummary(summaryPath);
            summary = JSCEResultsHelper.decorateSummary(summary);
            save(summaryPath, "summary", "cfg", "runRoot");
            JSCEResultsHelper.makeCriterionFigure(summary, outPath, style);
        end

        function [summary, cfg, runRoot] = loadSummary(summaryPath)
            init();
            loaded = load(summaryPath, "summary", "cfg", "runRoot");
            summary = loaded.summary;
            cfg = loaded.cfg;
            runRoot = loaded.runRoot;
        end

        function summary = decorateSummary(summary)
            summary = JSCEResultsHelper.refreshSummaryLabels(summary);
            summary.table1 = JSCEResultsHelper.buildRelativeTable(summary);
            summary.table2 = JSCEResultsHelper.buildSelectionTable(summary);
        end

        function summary = buildSummary(runRoot, cfg)
            models = string(cfg.genList);
            Nlist = double(cfg.Nlist(:)).';
            G = numel(models);
            F = numel(models);
            K = numel(Nlist);
            metrics = ["slsc", "slsc_x", "aic"];

            summary = struct();
            summary.models = models;
            summary.labels = strings(1, G);
            summary.Nlist = Nlist;
            summary.rep = cfg.rep;
            summary.runRoot = string(runRoot);
            summary.metricNames = metrics;
            summary.stats = struct();
            summary.selection = struct();

            for mi = 1:numel(metrics)
                metric = metrics(mi);
                summary.stats.(metric) = struct( ...
                    "mean", NaN(G, F, K), ...
                    "std", NaN(G, F, K), ...
                    "validRate", NaN(G, F, K));
                summary.selection.(metric) = NaN(G, K);
            end

            for gi = 1:G
                gen = models(gi);
                trueIdx = gi;

                for ni = 1:K
                    N = Nlist(ni);
                    metricMatrix = struct();
                    validMatrix = false(cfg.rep, F);
                    for mi = 1:numel(metrics)
                        metricMatrix.(metrics(mi)) = NaN(cfg.rep, F);
                    end

                    for fi = 1:F
                        fit = models(fi);
                        tag = sprintf("N%d_%s2%s", N, gen, fit);
                        aggPath = fullfile(runRoot, tag, "aggregate.mat");
                        S = load(aggPath, "allMetrics", "exitflagArray");

                        valid = true(numel(S.allMetrics.(metrics(1))), 1);
                        if isfield(S, "exitflagArray")
                            valid = S.exitflagArray > 0;
                        end
                        validMatrix(:, fi) = valid(:);

                        for mi = 1:numel(metrics)
                            metric = metrics(mi);
                            vals = S.allMetrics.(metric);
                            vals = vals(:);
                            goodVals = vals(valid);
                            summary.stats.(metric).mean(gi, fi, ni) = mean(goodVals, "omitnan");
                            summary.stats.(metric).std(gi, fi, ni) = std(goodVals, 0, "omitnan");
                            summary.stats.(metric).validRate(gi, fi, ni) = mean(valid);
                            metricMatrix.(metric)(:, fi) = vals;
                        end
                    end

                    for mi = 1:numel(metrics)
                        metric = metrics(mi);
                        M = metricMatrix.(metric);
                        M(~validMatrix) = inf;
                        M(~isfinite(M)) = inf;
                        hasFinite = any(isfinite(M), 2);
                        [~, idx] = min(M(hasFinite, :), [], 2);
                        summary.selection.(metric)(gi, ni) = mean(idx == trueIdx);
                    end
                end
            end
        end

        function summary = refreshSummaryLabels(summary)
            G = numel(summary.models);
            summary.labels = strings(1, G);
            for gi = 1:G
                summary.labels(gi) = JSCEResultsHelper.label(summary.models(gi));
            end
        end

        function table1 = buildRelativeTable(summary)
            models = summary.models;
            labels = summary.labels;
            ln3Idx = find(models == "lnormal", 1);
            G = numel(models);
            K = numel(summary.Nlist);
            hasLn3 = ~isempty(ln3Idx);

            table1 = struct();
            table1.rowLabels = labels;
            if hasLn3
                table1.colLabels = [labels(models ~= "lnormal"), "LN3(X)", "LN3(S)"];
            else
                table1.colLabels = labels;
            end
            table1.values = NaN(G, numel(table1.colLabels));

            keepModels = models;
            if hasLn3
                keepModels = models(models ~= "lnormal");
            end
            col = 1;
            for m = keepModels
                fi = find(models == m, 1);
                for gi = 1:G
                    ratios = NaN(1, K);
                    for ni = 1:K
                        denom = summary.stats.slsc_x.mean(gi, gi, ni);
                        numer = summary.stats.slsc_x.mean(gi, fi, ni);
                        ratios(ni) = numer / denom;
                    end
                    table1.values(gi, col) = mean(ratios, "omitnan");
                end
                col = col + 1;
            end

            if hasLn3
                for gi = 1:G
                    ratiosX = NaN(1, K);
                    ratiosS = NaN(1, K);
                    for ni = 1:K
                        denom = summary.stats.slsc_x.mean(gi, gi, ni);
                        ratiosX(ni) = summary.stats.slsc_x.mean(gi, ln3Idx, ni) / denom;
                        ratiosS(ni) = summary.stats.slsc.mean(gi, ln3Idx, ni) / denom;
                    end
                    table1.values(gi, end-1) = mean(ratiosX, "omitnan");
                    table1.values(gi, end) = mean(ratiosS, "omitnan");
                end
            end
        end

        function table2 = buildSelectionTable(summary)
            table2 = struct();
            table2.rowLabels = summary.labels;
            table2.colLabels = ["X-space SLSC", "S-space SLSC", "AIC"];
            table2.values = [ ...
                mean(summary.selection.slsc_x, 2, "omitnan"), ...
                mean(summary.selection.slsc, 2, "omitnan"), ...
                mean(summary.selection.aic, 2, "omitnan")];
        end

        function outPath = makeScalingFigure(summary, outPath, style)
            if nargin < 3
                style = struct();
            end
            style = JSCEResultsHelper.scalingStyleDefaults(style, numel(summary.models));

            fig = figure("Visible", "off", "Position", style.figurePosition);
            tl = tiledlayout(style.rows, style.cols, ...
                "TileSpacing", style.tileSpacing, ...
                "Padding", style.padding);
            handles = gobjects(numel(summary.models) + 1, 1);

            for gi = 1:numel(summary.models)
                nexttile;
                hold on;
                trueCurve = squeeze(summary.stats.slsc_x.mean(gi, gi, :)).';
                refIdx = find(isfinite(trueCurve), 1, "first");
                refLine = trueCurve(refIdx) * sqrt(summary.Nlist(refIdx) ./ summary.Nlist);

                for fi = 1:numel(summary.models)
                    mu = squeeze(summary.stats.slsc_x.mean(gi, fi, :)).';
                    sd = squeeze(summary.stats.slsc_x.std(gi, fi, :)).';
                    h = loglog(summary.Nlist, mu, style.lineSpec, ...
                        "LineWidth", style.lineWidth, ...
                        "MarkerSize", style.markerSize, ...
                        "Color", style.colors(fi, :), ...
                        "MarkerFaceColor", style.colors(fi, :));
                    if gi == 1
                        handles(fi) = h;
                    end
                    JSCEResultsHelper.drawErrorBars(summary.Nlist, mu, sd, ...
                        style.colors(fi, :), style.errorBarWidth);
                end

                href = loglog(summary.Nlist, refLine, style.referenceLineSpec, ...
                    "Color", style.referenceColor, ...
                    "LineWidth", style.referenceLineWidth);
                if gi == 1
                    handles(end) = href;
                end

                title(summary.labels(gi));
                xlabel(style.xLabel);
                ylabel(style.yLabel);
                set(gca, "XScale", "log", "YScale", "log");
                xticks(summary.Nlist);
                xticklabels(string(summary.Nlist));
                grid on;
                box on;
            end

            lgd = legend(handles, [summary.labels, style.referenceLabel], ...
                "Orientation", style.legendOrientation);
            lgd.Layout.Tile = style.legendTile;
            exportgraphics(fig, outPath, "ContentType", "vector");
            close(fig);
        end

        function outPath = makeCriterionFigure(summary, outPath, style)
            if nargin < 3
                style = struct();
            end
            style = JSCEResultsHelper.criterionStyleDefaults(style);

            fig = figure("Visible", "off", "Position", style.figurePosition);
            tl = tiledlayout(style.rows, style.cols, ...
                "TileSpacing", style.tileSpacing, ...
                "Padding", style.padding);
            critLabels = ["X-space SLSC", "S-space SLSC", "AIC"];
            critFields = ["slsc_x", "slsc", "aic"];
            handles = gobjects(numel(critFields), 1);

            for gi = 1:numel(summary.models)
                nexttile;
                hold on;
                for ci = 1:numel(critFields)
                    y = summary.selection.(critFields(ci))(gi, :);
                    h = plot(summary.Nlist, y, style.lineSpec, ...
                        "LineWidth", style.lineWidth, ...
                        "Color", style.colors(ci, :), ...
                        "Marker", style.markers(ci), ...
                        "MarkerSize", style.markerSize, ...
                        "MarkerFaceColor", style.colors(ci, :));
                    if gi == 1
                        handles(ci) = h;
                    end
                end
                ylim(style.yLimits);
                xlim([min(summary.Nlist), max(summary.Nlist)]);
                xticks(summary.Nlist);
                title(summary.labels(gi));
                xlabel(style.xLabel);
                ylabel(style.yLabel);
                grid on;
                box on;
            end

            lgd = legend(handles, critLabels, ...
                "Orientation", style.legendOrientation);
            lgd.Layout.Tile = style.legendTile;
            exportgraphics(fig, outPath, "ContentType", "vector");
            close(fig);
        end

        function printTablePreview(summary)
            disp("Table 1 preview (relative SLSC, averaged over N values):");
            JSCEResultsHelper.printTable(summary.table1, true);
            disp("Table 2 preview (true-model selection rate, averaged over N values):");
            JSCEResultsHelper.printTable(summary.table2, false);
        end

        function printTable(tbl, highlightBelowOne)
            header = "sampler";
            for c = 1:numel(tbl.colLabels)
                header = header + sprintf("\t%s", tbl.colLabels(c));
            end
            disp(header);
            for r = 1:numel(tbl.rowLabels)
                lineText = tbl.rowLabels(r);
                for c = 1:numel(tbl.colLabels)
                    val = tbl.values(r, c);
                    token = sprintf("%.3f", val);
                    if highlightBelowOne && val < 1 - 1e-12
                        token = "[" + token + "]";
                    end
                    lineText = lineText + sprintf("\t%s", token);
                end
                disp(lineText);
            end
        end

        function figDir = figureDir()
            figDir = fullfile(JSCEResultsHelper.repoRoot(), "paper", "jsce", "fig", "results");
            if ~isfolder(figDir)
                mkdir(figDir);
            end
        end

        function summaryPath = defaultSummaryPath()
            summaryPath = fullfile(JSCEResultsHelper.figureDir(), "results_summary_short.mat");
        end

        function models = modelList()
            models = ["gumbel", "gev", "lgamma", "sqrtet", "exponential", "lnormal"];
        end

        function label = label(model)
            switch string(model)
                case "gumbel"
                    label = "Gumbel";
                case "gev"
                    label = "GEV";
                case "lgamma"
                    label = "LP3";
                case "sqrtet"
                    label = "SqrtEt";
                case "exponential"
                    label = "Exp";
                case "lnormal"
                    label = "LN3";
                otherwise
                    label = string(model);
            end
        end

        function repoRoot = repoRoot()
            thisFile = which("JSCEResultsHelper");
            scriptDir = fileparts(thisFile);
            jsceRoot = fileparts(scriptDir);
            paperRoot = fileparts(jsceRoot);
            repoRoot = fileparts(paperRoot);
        end
    end

    methods(Static, Access = private)
        function opts = normalizeOptions(opts)
            base = JSCEResultsHelper.defaultOptions();
            fields = fieldnames(base);
            for i = 1:numel(fields)
                key = fields{i};
                if ~isfield(opts, key)
                    opts.(key) = base.(key);
                end
            end
            opts.models = string(opts.models);
            opts.Nlist = double(opts.Nlist(:)).';
        end

        function style = scalingStyleDefaults(style, nModels)
            defaults = struct();
            defaults.figurePosition = [80 80 1280 860];
            defaults.rows = 2;
            defaults.cols = 3;
            defaults.tileSpacing = "compact";
            defaults.padding = "compact";
            defaults.colors = lines(nModels);
            defaults.lineSpec = "-o";
            defaults.lineWidth = 1.5;
            defaults.markerSize = 5;
            defaults.errorBarWidth = 1.0;
            defaults.referenceLineSpec = "--";
            defaults.referenceColor = [0.2 0.2 0.2];
            defaults.referenceLineWidth = 1.4;
            defaults.referenceLabel = "N^{-1/2}";
            defaults.xLabel = "N";
            defaults.yLabel = "X-space SLSC";
            defaults.legendOrientation = "horizontal";
            defaults.legendTile = "south";

            style = JSCEResultsHelper.fillMissingStyle(style, defaults);
        end

        function style = criterionStyleDefaults(style)
            defaults = struct();
            defaults.figurePosition = [80 80 1240 860];
            defaults.rows = 2;
            defaults.cols = 3;
            defaults.tileSpacing = "compact";
            defaults.padding = "compact";
            defaults.colors = [0.10 0.25 0.60; 0.82 0.22 0.18; 0.15 0.55 0.22];
            defaults.lineSpec = "-";
            defaults.markers = ["o", "s", "^"];
            defaults.lineWidth = 1.8;
            defaults.markerSize = 6;
            defaults.xLabel = "N";
            defaults.yLabel = "True-model selection rate";
            defaults.yLimits = [0, 1];
            defaults.legendOrientation = "horizontal";
            defaults.legendTile = "south";

            style = JSCEResultsHelper.fillMissingStyle(style, defaults);
        end

        function style = fillMissingStyle(style, defaults)
            keys = fieldnames(defaults);
            for i = 1:numel(keys)
                key = keys{i};
                if ~isfield(style, key)
                    style.(key) = defaults.(key);
                end
            end
        end

        function drawErrorBars(x, mu, sd, color, width)
            for i = 1:numel(x)
                if ~(isfinite(mu(i)) && isfinite(sd(i)))
                    continue;
                end
                lo = max(mu(i) - sd(i), mu(i) * 0.2);
                hi = mu(i) + sd(i);
                line([x(i), x(i)], [lo, hi], "Color", color, "LineWidth", width);
            end
        end

        function out = buildOutput(runRoot, summaryPath, fig1Path, fig2Path, summary)
            out = struct();
            out.runRoot = string(runRoot);
            out.summaryPath = string(summaryPath);
            out.figurePaths = struct( ...
                "slscScaling", string(fig1Path), ...
                "criterionCompare", string(fig2Path));
            out.table1 = summary.table1;
            out.table2 = summary.table2;
        end
    end
end
