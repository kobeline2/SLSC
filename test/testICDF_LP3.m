% Usage
% >> results = runtests("testICDF_LP3");
% >> table(results)
%

classdef testICDF_LP3 < matlab.unittest.TestCase
    properties(Constant)
        % log-Pearson type III parameters in log space
        theta = struct('a', 0.35, 'b', 2.4, 'c', 3.4);
        tol   = 1e-10;
    end

    methods(Test)
        function roundTrip(test)
            u  = linspace(1e-6, 1-1e-6, 201).';
            x  = simstudy.distributions.icdf_lp3(u, test.theta);
            u2 = simstudy.distributions.cdf("lp3", x, test.theta);

            test.verifyLessThanOrEqual(max(abs(u - u2)), test.tol, ...
                "Round-trip error exceeds tolerance");
        end

        function monotonicity(test)
            u  = rand(1e4, 1);
            x  = simstudy.distributions.icdf_lp3(u, test.theta);

            [~, idx] = sort(u);
            dx = diff(x(idx));
            test.verifyGreaterThanOrEqual(min(dx), 0, ...
                "ICDF output is not monotonically increasing");
        end
    end
end
