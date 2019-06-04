clear;
clc;
format compact;
close all;

a = 2;
Ts = 5 / (a * pi);

xt = @(a, t) exp(-((t./a).^2)./2);
xw = @(a, w) a .* sqrt(2 .* pi) .* exp(-((a .* w).^2)./2);

nyquestSampleIntervals = -5 * a : Ts : 5 * a;
N = ceil(length(nyquestSampleIntervals)/2);
nyquestSamples = xt(a, nyquestSampleIntervals);

newSinc = @(x) sin(x)./x + (x == 0);

reconSampling = linspace(-5 * a, 5 * a, 1000);

reconSignal = xt(a, reconSampling) .* newSinc((pi .* (reconSampling - (-N) .* Ts))./Ts);
hold on;

% Create the xy plot for the reconstructed signal in position 4 of a 2x2 grid
subplot(3, 1, 3);
axis([-10 10 -0.5 1.2]);
xlabel('Time');
ylabel('Signal');
title('Reconstructed Signal');
hold on;

for i = -N+1:N
    newContribute = xt(a, reconSampling) .* newSinc((pi .* (reconSampling - i .* Ts))./Ts);
    reconSignal = reconSignal + newContribute;
    plot(reconSampling, newContribute);
end
plot(reconSampling, reconSignal, 'r--');
hold off;

t = linspace(-5 * a, 5 * a, 1000);
w = linspace(-5/a, 5/a, 1000);

subplot(3, 1, 1);
hold on;
plot(t, xt(a, t), 'r--');
stem(nyquestSampleIntervals, nyquestSamples);
hold off;
axis([-10 10 0 1.2]);
xlabel('Time');
ylabel('Signal');
title('x(t) of Gaussian Signal');

subplot(3, 1, 2);
plot(w, xw(a, w));
xlabel('Angular Frequency');
ylabel('Signal'); 
title('x(w) of Gaussian Signal');