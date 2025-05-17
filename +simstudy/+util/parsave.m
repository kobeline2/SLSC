function parsave(fname, metrics, fitRes, obs)
% A thin wrapper so that parfor sees one function call.
save(fname, 'metrics', 'fitRes', 'obs');
end