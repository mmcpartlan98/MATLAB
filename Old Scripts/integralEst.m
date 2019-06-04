% integrate.m

function [trapezoidRS, midpointRS, absoluteErrorTrap, absoluteErrorMidpt] = integralEst(f_x, xmin, xmax, N)
digits(64);
a = xmin;
b = xmax;
x = linspace(a, b, (N+1));
delta_x = (b - a)/N;

x_i = x(1:N);
x_e = x(2:N+1);
trapRS = (2.*f_x(x(2:N)));
trapezoidRS = (delta_x/2).*(sum(trapRS) + f_x(x(N+1)) + f_x(x(1)));
fprintf('Trapezoid Approximation: %1.8f\n', trapezoidRS);
midptRS = f_x((x_i + x_e)./2);
midpointRS = delta_x.*sum(midptRS);
fprintf('Midpoint Approximation: %1.8f\n', midpointRS);
fprintf('Analytcal Value: %1.8f\n', integral(f_x, xmin, xmax));

absoluteErrorTrap = abs(integral(f_x, xmin, xmax) - trapezoidRS);
absoluteErrorMidpt = abs(integral(f_x, xmin, xmax) - midpointRS);

fprintf('Absolute Error TrapRS: %1.8f\n', absoluteErrorTrap);
fprintf('Absolute Error MidptRS: %1.8f\n', absoluteErrorMidpt);