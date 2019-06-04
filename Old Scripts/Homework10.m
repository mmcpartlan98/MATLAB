clear;
clc;
format compact;
close all;

Ts = 0.004;
lowerPlotBound = -0.05;
upperPlotBound = 0.05;

plotPoints = linspace(lowerPlotBound, upperPlotBound, 1000);
samplePoints = lowerPlotBound:Ts:upperPlotBound;

newSinc = @(x) sin(x)./x + (x == 0);

xt = @(t) newSinc(200 * pi * t);
xw = @(w) rectangularPulse(1250 .* w);

hold on;

% Create the xy plot for the reconstructed signal in position 4 of a 2x2 grid
subplot(3, 1, 3);
xlabel('Time');
ylabel('Signal');
title('Reconstructed Signal');
hold on;

subplot(3, 1, 1);
hold on;
plot(plotPoints, xt(plotPoints));
stem(samplePoints, xt(samplePoints));
hold off;
xlabel('Time');
ylabel('Signal');
title('x(t) of Gaussian Signal');

w = linspace(-1000*pi, 1000*pi, 1000);

subplot(3, 1, 2);
plot(w, xw(w));
xlabel('Angular Frequency');
ylabel('Signal'); 
title('x(w) of Gaussian Signal');