clear;
clc;
format compact;
close all;

N = 150;
w = 2*pi;
time = 10;

dn = @(n, w) (-1/(1i*n*w + 1)) * (exp(-(1 + 1j*n*w)) - 1);

d0 = 1/4;

finalSignal = 0;
shapedSignal = 0;
t = linspace(0, time, 1000);

inputs = -N:N;
outputs = -N:N;

for i = 1:(2*N + 1)
    outputs(i) = dn(inputs(i), w);
    if i == N + 1
        outputs(i) = -exp(-1) + 1;
    end
    n = i - N - 1;
    finalSignal = finalSignal + outputs(i) * exp(1i * n * w .* t);
    shapedSignal = shapedSignal + outputs(i) * exp(1i * n * w .* t) * (1/(1 + 1i*n*w));
end

hold on;
subplot(3, 1, 1);
plot(t, real(finalSignal), t, real(shapedSignal), 'r--');
xlabel('Time');
ylabel('Signal');
title('Fourier Approximation (99.99%)');

subplot(3, 1, 2);
stem(inputs(((N-10):(N+10)) + 1), angle(outputs(((N-10):(N+10)) + 1)));
axis([-10 10 -5 5]);
xlabel('Harmonic');
ylabel('Angle');
title('Coefficient Phase Plot');

% Create the xy plot for the reconstructed signal in position 4 of a 2x2 grid
subplot(3, 1, 3);
stem(inputs(((N-10):(N+10)) + 1), abs(outputs(((N-10):(N+10)) + 1)));
axis([-10 10 -0.1 0.75]);
xlabel('Harmonic');
ylabel('Magnitude');
title('Coefficient Magnitude Plot');