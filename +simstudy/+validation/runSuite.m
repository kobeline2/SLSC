function reports = runSuite(modelList, opts)
%RUNSUITE Run distribution checks for multiple models and save an index CSV.

arguments
    modelList string
    opts.RootDir string = ""
    opts.N (1,1) double {mustBeInteger, mustBePositive} = 500
    opts.GridSize (1,1) double {mustBeInteger, mustBePositive} = 200
    opts.RoundTripTol (1,1) double {mustBePositive} = 1e-6
    opts.Seed (1,1) double = 42
end

reports = repmat(struct(), numel(modelList), 1);
rows = table();

for i = 1:numel(modelList)
    model = modelList(i);
    saveDir = "";
    if strlength(opts.RootDir) > 0
        saveDir = fullfile(opts.RootDir, model);
    end

    report = simstudy.validation.runDistributionCheck(model, ...
        "N", opts.N, ...
        "GridSize", opts.GridSize, ...
        "RoundTripTol", opts.RoundTripTol, ...
        "SaveDir", saveDir, ...
        "Seed", opts.Seed + i - 1);
    reports(i) = report;
    rows = [rows; localRow(report)]; %#ok<AGROW>
end

if strlength(opts.RootDir) > 0
    csvPath = fullfile(opts.RootDir, "index.csv");
    writetable(rows, csvPath);
end
end

function row = localRow(report)
checks = report.checks;
row = table( ...
    report.model, ...
    localStatus(checks.roundTrip), ...
    localStatus(checks.cdfMonotone), ...
    localStatus(checks.pdfNonnegative), ...
    localStatus(checks.loglikeFinite), ...
    localStatus(checks.mleSelfFit), ...
    report.files.figure, ...
    'VariableNames', ...
    {'model','roundTrip','cdfMonotone','pdfNonnegative','loglikeFinite','mleSelfFit','figure'});
end

function s = localStatus(item)
if isfield(item, "error")
    s = "error";
elseif item.ok
    s = "ok";
else
    s = "fail";
end
end
