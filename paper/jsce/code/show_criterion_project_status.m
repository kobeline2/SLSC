function tbl = show_criterion_project_status()
%SHOW_CRITERION_PROJECT_STATUS Show which (gen, N) cases are done.

opts = struct();

% ----- Edit here -------------------------------------------------------
opts.projectName = "learn_smoke";
% opts.projectName = "paper_main";
% ----------------------------------------------------------------------

tbl = criterion_project("status", opts);
end
