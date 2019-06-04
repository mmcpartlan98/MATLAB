% Matt McPartlan
% Homework 13, Problem 1
% April 19, 2017
% This program calls the arMethod function to generate 10000 random points
% under the distribution curve defined by eqn. 

clear;
clc;
format compact;

N = 10000;

pdf = @(x) (x >= 0).*(x./10).*exp(1).^(-x.^(2)/20);
distribution = arMethod(pdf, 0, 20, N, 0, 1, 2);
x = linspace(0, 20, 1000);
figure;
subplot(2, 1, 1);
hold on;
plot(x, pdf(x));
scatter(distribution(1, :), distribution(2, :), 'r.');
title('f(x) W/ Scatter Distribution');
subplot(2, 1, 2);
histogram(distribution(1, :), 'BinEdges', 0:0.1:20);
title('Histogram (x-values) of Scatter Distribution');