function mx = structMax(S)
%STRUCTMAX  Return the maximum numeric value in a (nested) struct.
%
%   mx = structMax(S)
%
%   • S may be a scalar struct or a struct array.
%   • The function descends recursively into sub-struct fields.
%   • Non-numeric fields are skipped.

    mx = -inf;

    if isstruct(S)
        % Iterate over all elements in struct array, if any
        for idx = 1:numel(S)
            fn = fieldnames(S(idx));
            for k = 1:numel(fn)
                val = S(idx).(fn{k});
                if isstruct(val)
                    mx = max(mx, structMax(val));         % recursion
                elseif isnumeric(val) && ~isempty(val)
                    mx = max(mx, max(val(:)));
                end
            end
        end
    elseif isnumeric(S)          % fallback if user passes numeric
        mx = max(S(:));
    end
end