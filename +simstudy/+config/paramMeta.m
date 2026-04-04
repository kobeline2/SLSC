function meta = paramMeta(model)
%PARAMMETA  Return parameter specification for each model.
%
%   meta = struct array, each element:
%       .name      - field name in theta
%       .domain    - 'pos' | 'real' | 'neg' | 'unit' | custom
%
model = lower(string(model));
if model == "norm"
    model = "normal";
end

switch model
    case "normal"
        meta = [ ...
            struct('name','mu'   ,'domain','real');  
            struct('name','sigma','domain','pos') ];
    case "lgamma"
        meta = [ ...
            struct('name','a','domain','pos');  
            struct('name','b','domain','pos') ;
            struct('name','c','domain','real')];
    case "sqrtet"
        meta = [ ...
            struct('name','a','domain','pos');   
            struct('name','b','domain','pos') ];
    case "gumbel"
        meta = [ ...
            struct('name','alpha','domain','real');  
            struct('name','beta' ,'domain','pos') ];
    case "gev"
        meta = [ ...
            struct('name','k',     'domain','real');
            struct('name','sigma', 'domain','pos');
            struct('name','mu',    'domain','real') ];
    case "lnormal"
        meta = [ ...
            struct('name','c',     'domain','real');
            struct('name','mu',    'domain','real');
            struct('name','sigma', 'domain','pos') ];
    case "exponential"
        meta = [ ...
            struct('name','c',  'domain','real');
            struct('name','mu', 'domain','pos')];
    otherwise
        error('Unknown model %s',model);
end
end
