clear;
clc;
format compact;

N = 10000;
dt = 0.001;
x_axis = linspace(-1, N * dt, 1000);

xt = @(t) 1 .* (t >= 0) - 1 .* (t >= 2) + 1 .* (t >= 4) - 1 .* (t >= 6);
yt = @(t) sin(2.*t) .* (t >= 0) .* (t <= pi);

convolutionSum = 0;

for i = -N:N
   convolutionSum = convolutionSum + xt(i .* dt) .* yt(x_axis - i .* dt) .* dt;
end


hold on;
plot(x_axis, xt(x_axis));
plot(x_axis, yt(x_axis), "g")
plot(x_axis, convolutionSum, "--r");
title("Xt (blue), Yt (green), and X * Y (Red)");
xlabel("Time");
ylabel("Magnitude");