clear;
clc;
format compact;
close all;

w = pi/4;
time = 8;

seg1 = @(n, w) 1 - (2*1i*n*w + 1) * exp(-2*1i*n*w) - exp(-4*1i*n*w) + (2*1i*n*w + 1) * exp(-6*1i*n*w);
dn = @(n, w) (1/8) * (1/2) * (1/(1i*n*w)^2) * seg1(n, w);

signal = @(t) 0.5*t.*((t > 0) & (t <= 2)) + ...
    (-0.5*t + 2) .* ((t > 4) & (t <= 6));

d0 = 1/4;

finalSignal = 0;
t = linspace(0, time, 1000);

x = 0;
time_power = 1/6;
power = 0;

while power<0.99*time_power
    x = x + 1;
    power = power + 2*abs(dn(x, w))^2;
end

fprintf('99%% Power Approximation:\n');
fprintf('N: %f\n', x);
fprintf('Power: %f\n', power);

x = 0;
time_pow = 1/6;
power = 0;

while power<0.9999*time_power
    x = x + 1;
    power = power + 2*abs(dn(x, w))^2;
end

N = x;
inputs = -N:N;
outputs = -N:N;

for i = 1:(2*N + 1)
    outputs(i) = dn(inputs(i), w);
    if i == N + 1
        outputs(i) = 0;
    end
    n = i - N - 1;
    finalSignal = finalSignal + outputs(i) * exp(1i * n * w .* t);
end

fprintf('99.99%% Power Approximation:\n');
fprintf('N: %f\n', x);
fprintf('Power: %f\n', power);

hold on;
subplot(3, 1, 1);
plot(t, real(finalSignal), t, signal(t), 'r--');
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
axis([-10 10 -0.1 0.3]);
xlabel('Harmonic');
ylabel('Magnitude');
title('Coefficient Magnitude Plot');