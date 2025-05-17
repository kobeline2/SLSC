function ll = loglike_sqrtet(x, theta)
a = theta.a; 
b = theta.b;
c = log(2/a/b);
sbx = sqrt(b*x);
ll = sum(-c -sbx - a*(1+sbx) .* exp(-sbx));

end