% 使い方
% >> results = runtests("testICDF_LGamma");
% >> table(results)
%

classdef testICDF_LGamma < matlab.unittest.TestCase
    properties(Constant)
        % choose some non-trivial parameters
        theta = struct('a', 2.3, 'b', 1.7, 'c', 0.4);
        tol   = 1e-10;   % numerical tolerance for round-trip
    end

    methods(Test)
        function roundTrip(test)
            % deterministic u grid avoids random flukes
            u  = linspace(1e-6, 1-1e-6, 201).';
            x  = simstudy.distributions.icdf_lgamma(test.theta, u);
            u2 = simstudy.distributions.cdf( "lgamma", test.theta, x );

            test.verifyLessThanOrEqual( max(abs(u-u2)), test.tol, ...
                "Round-trip error exceeds tolerance");
        end

        function monotonicity(test)
            u  = rand(1e4,1);     % random uniform
            x  = simstudy.distributions.icdf_lgamma(test.theta, u);

            [~,idx] = sort(u);
            dx      = diff(x(idx));
            test.verifyGreaterThanOrEqual( min(dx), 0, ...
                "ICDF output is not monotonically increasing");
        end
    end
end