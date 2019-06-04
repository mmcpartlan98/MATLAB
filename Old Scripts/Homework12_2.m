clear;
clc;
format compact;

W = linspace(-10, 10, 1000);

Yn = (exp(1i .* W) .* exp(1i .* W))./(exp(1i .* W) - 0.5);

figure;
subplot(2, 1, 1);
plot(W, abs(Yn));

xlabel('Omega');
ylabel('Magnitude');

subplot(2, 1, 2);
plot(W, angle(Yn));
xlabel('Omega');
ylabel('Angle');