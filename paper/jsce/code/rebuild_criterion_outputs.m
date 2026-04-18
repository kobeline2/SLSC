function out = rebuild_criterion_outputs()
%REBUILD_CRITERION_OUTPUTS Rebuild summary / CSV / TeX / figure from saved cases.
%
% Use this after running a few more cases over several days.

opts = struct();

% ----- Edit here -------------------------------------------------------
opts.projectName = "learn_smoke";
% opts.projectName = "paper_main";
opts.publishToPaper = false;
% ----------------------------------------------------------------------

out = criterion_project("rebuild", opts);
end
