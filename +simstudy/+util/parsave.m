function parsave(fname, metrics, fitRes)
% A thin wrapper so that parfor sees one function call.
save(fname, 'metrics', 'fitRes');
end