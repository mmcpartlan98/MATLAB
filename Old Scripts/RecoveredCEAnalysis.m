clear;
clc;
format compact;

i_c = 0.010;
beta = 150;
r_eac = 3;
r_l = 500;
vcc = 15;

v_th = vcc/2;
i_b = i_c/beta;
i_e = i_b + i_c;
r_c = ((vcc-vcc*0.15)/2)/i_c;
r_e = (3/i_e)/(1/beta + 1);
r_th = 12000;

r_pi = 0.026/i_b;
r_edc = r_e - r_eac;
Av = -(beta/(r_pi + (beta + 1)*r_eac)) * ...
    (r_c^(-1) + r_l^(-1))^(-1) * ((r_th^(-1) + ...
    (r_pi + (beta + 1)*r_eac)^(-1))^(-1)) / ...
    ((r_th^(-1) + (r_pi + (beta + 1) * r_eac)^(-1))^(-1) + 100);

fprintf('Av (B = 150, load = 500): %f\n', Av);

beta = 250;
r_l = 750;

Av = -(beta/(r_pi + (beta + 1)*r_eac)) * ...
    (r_c^(-1) + r_l^(-1))^(-1) * ((r_th^(-1) + ...
    (r_pi + (beta + 1)*r_eac)^(-1))^(-1)) / ...
    ((r_th^(-1) + (r_pi + (beta + 1) * r_eac)^(-1))^(-1) + 100);

fprintf('Av (B = 250, load = 750): %f\n', Av);
fprintf('r_c: %f\n', r_c);
fprintf('r_eac: %f\n', r_eac);
fprintf('r_edc: %f\n', r_edc);
fprintf('r_th: %f\n', r_th);
