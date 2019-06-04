clear;
clc;
format compact;
close all;

a = 1;
N = 10;

prob1a = @(a, w) 1./(a - 1i.*w);
prob1b = @(a, w) (2*a)./((a.^2) + (w.^2));
prob1c = @(a, w) 1./((a + 1i*w).^2);

xAxis = linspace(-N, N, 1000);

subplot(2, 1, 1);
plot(xAxis, abs(prob1b(a, xAxis)));
xlabel('Omega');
ylabel('Magnitude');
title('Problem 1b Magnitude Plot');

subplot(2, 1, 2);
plot(xAxis, abs(prob1c(a, xAxis)));
xlabel('Omega');
ylabel('Magnitude');
title('Problem 1c Magnitude Plot');