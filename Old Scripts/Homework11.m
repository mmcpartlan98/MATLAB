clear;
clc;
format compact;
close all;

Ts = 0.004;
D0 = 0.2;
numberOfPlotPoints = 1000;

xt = @(t) newSinc(200 .* pi .* t);
Dn = @(n, t) ((exp(1i .* 0.628 .* n) - exp(-1i .* 0.628 .* n))./(1i .* n .* 2 .* pi));
FTOriginal = @(w) rectangularPulse(w./(400 .* pi));

plotPoints = linspace(-0.05, 0.05, numberOfPlotPoints);
samplePoints = plotPoints(1):Ts:plotPoints(numberOfPlotPoints);
fPlotPoints = linspace(-1000 * pi, 1000 * pi, numberOfPlotPoints);

trueRect = @(n, t) rectangularPulse(1250 .* (t - n .* Ts));

newContribute = zeros(1, numberOfPlotPoints);
fNewContribute = zeros(1, numberOfPlotPoints);
plotRect = zeros(1, numberOfPlotPoints);
reconAttemptSum = zeros(1, numberOfPlotPoints);
underSamplePoints = plotPoints(1):2*Ts:plotPoints(numberOfPlotPoints);

fftTest = zeros(1, length(samplePoints));
fftUnder = zeros(1, length(underSamplePoints));

for n = -(length(samplePoints)/2):length(samplePoints)
    if n ~= 0
        fNewContribute = fNewContribute + Dn(n, fPlotPoints) .* exp(1i .* n .* 500 .* pi .* fPlotPoints);
        reconAttemptSum = reconAttemptSum + 2 .* pi .* Dn(n, fPlotPoints) .* (1/200) .* FTOriginal((fPlotPoints - n .* 500 .* pi));
    end
    if n == 0
        fNewContribute = fNewContribute + D0 * exp(1i .* n .* 500 .* pi .* fPlotPoints);
        reconAttemptSum = reconAttemptSum + 2 .* pi .* D0 .* (1/200) .* FTOriginal(fPlotPoints - n .* 500 .* pi);
    end
end

reconAttemptSum = abs(reconAttemptSum);

% Create the xy plot for the reconstructed signal in position 4 of a 2x2 grid
hold on;
subplot(2, 1, 1);
hold on;
plot(plotPoints, newSinc(200 .* pi .* plotPoints));
plot(plotPoints, newSinc(200 .* pi .* plotPoints), 'k--');
plot(plotPoints, (1/2) .* newSinc(100 .* pi .* plotPoints), 'r--');
stem(-0.05:(1/100):0.05, newSinc(200 .* pi .* (-0.05:(1/100):0.05)));
stem(-0.05:(1/250):0.05, newSinc(200 .* pi .* (-0.05:(1/250):0.05)));
hold off;
xlabel('Time');
ylabel('Signal');
title('Original Signal (time domain)');

subplot(2, 1, 2);
hold on;
plot(fPlotPoints, reconAttemptSum);
plot(fPlotPoints, reconAttemptSum .* rectangularPulse(fPlotPoints/(200 .* pi)), 'r--');
plot(fPlotPoints, reconAttemptSum .* rectangularPulse(fPlotPoints/(400 .* pi)), 'k--');
hold off;
xlabel('Angular Frequency');
ylabel('Signal'); 
title('Sampled Signal');