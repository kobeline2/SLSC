function y = pdf_sqrtet(x, theta)
% p = \frac{ab}{2} \exp \left[ -\sqrt{bx} -a(1+\sqrt{bx})\exp(-\sqrt{bx})   \right] (x \geq 0)
a = theta.a; b = theta.b;
c = 2/a/b;
sbx = sqrt(b*x);
y = exp(-sbx - a*(1+sbx) .* exp(-sbx)) / c;
end