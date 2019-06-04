clear;
clc;
format compact;

N = 6;
r = -N:N;

Dr = (1/6) .* (exp(1i .* r .* (2*pi/3)) + 2 .* exp(1i .* r .* (pi/3)) + 3 + 2 .* exp(-1i .* r .* (pi/3)) + exp(-1i .* r .* (2*pi/3)));

figure;
subplot(2, 1, 1);
stem(r, abs(Dr));

xlabel('Omega');
ylabel('Magnitude');

subplot(2, 1, 2);
stem(r, angle(Dr));
xlabel('Omega');
ylabel('Angle');