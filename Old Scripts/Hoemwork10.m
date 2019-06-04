clear;
clc;
format compact;
  
WSamples =  5 / 2; 
B =  WSamples / (2 * pi); 

nyquest =  2 * B; 
Ts =  1 / (2 * nyquest);

nyquest = floor(5 * 2 / Ts); 
n = -nyquest:nyquest; 


tSamples = linspace(-5 * 2, 5 * 2, 1000);
WSamples = linspace(-5 / 2, 5 / 2, 1000); 

signal = @(t) exp(-(t / 2) .^ 2 / 2); 
Xw = @(W) 2 * sqrt(2 * pi) * exp(-(2 * W) .^ 2 / 2); 

f  = zeros((2 * nyquest + 1), length(tSamples)); 
for  n  = -nyquest : nyquest 
    f(n + nyquest + 1, :)  =  signal(n * Ts) * sinc((tSamples - n * Ts)/ Ts); 
end

figure;
subplot(4, 1, 1); 
plot(tSamples, signal(tSamples)); 
title("Original Time Domain Signal");
xlabel( "x(w)") ; 
ylabel( "x(t)" ) ; 

subplot(4, 1, 2); 
plot(WSamples, Xw(WSamples)); 
title("Original Frequency Domain Signal");
xlabel('Rad/s'); 
ylabel('X(W)'); 

subplot(4, 1, 3);
stem(n * Ts, signal(n * Ts)); 
title("Sampled Time Domain Signal");
xlabel('nTs'); 
ylabel('x(nTs)'); 
hold on; 
plot (tSamples, signal(tSamples)); 
hold off; 

subplot(4, 1, 4);
plot (tSamples, signal(tSamples), tSamples, f, " r-- ") ;
title("Sinc-reconstructed Signal (should match 1)");
xlabel('t'); 
ylabel('x(t)'); 