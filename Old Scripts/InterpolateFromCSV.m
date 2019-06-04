clear;
clc
format compact;

data = csvread('ThevEq2.csv');
x_interp= linspace(data(1, 1), data(7, 1));

toPlot = interp1(data(1:7, 1), data(1:7, 3),x_interp, 'spline');
interp_xmax = x_interp(toPlot == max(toPlot));
interp_ymax = max(toPlot);

figure
plot(data(1:7, 1), data(1:7, 3), 'o', x_interp ,toPlot, ':.');
title('Spline Interpolation: Thevenin Eq. of Circuit 3');
xlabel('Resistance (Ohms)');
ylabel('Power (mW)');

infoStr = sprintf('Maximum: %.2f mW at %.2f Ohms', interp_ymax, interp_xmax);
dim = [.49 .62 .3 .3];
annotation('textbox',dim,'String',infoStr,'FitBoxToText','on');

hold on;
plot(interp_xmax, interp_ymax,'r*');