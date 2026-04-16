addpath('/Users/takahiro/Documents/git/SLSC/paper/jsce/scripts')
out = run_results_custom();
で回して、図だけ直したいときは

% Example: out.summaryPath = '/Users/takahiro/Documents/git/SLSC/paper/jsce/fig/results/results_summary_short.mat'
make_slsc_n_scaling_figure(out.summaryPath)
make_criterion_compare_figure(out.summaryPath)