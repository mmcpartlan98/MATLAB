clc;
clear;
format compact;

i_c = 0.010;
beta = 150;
vcc = 15;
r_l = 10000;
r_in = 750;       % Must match R_load from CE amplifier stage
r_s = 637.5;        % R_out = R_c of CE amplifier stage

v_re = vcc * 0.15; % General practice: drop 15% of vcc across R_E
i_b = i_c/beta;
r_e = (v_re)/(i_b * (beta + 1));
r_pi = 0.026/i_b;
%r_th = 1/((1/r_in) - (1/(r_pi + (beta + 1)*(1/((1/r_e)+(1/r_l))))));
r_out = 1/((1/r_e) + 1/((r_pi+(1/(1/r_th) + (1/r_s)))/(beta + 1)));

Av = (r_in/(r_in + r_s))*(((beta + 1)*r_e)/(r_pi+(beta+1)*r_e))*(r_l/(r_l+r_out));

fprintf('Av (B = %0.2f, load = %0.2f): %f\n', beta, r_l, Av);

beta = 250;

Av = (r_in/(r_in + r_s))*(((beta + 1)*r_e)/(r_pi+(beta+1)*r_e))*(r_l/(r_l+r_out));

fprintf('Av (B = %0.2f, load = %0.2f): %f\n', beta, r_l, Av);
fprintf('R_E: %0.1f\n', r_e);
fprintf('R_B1/B2: %0.1f\n', r_th*2);