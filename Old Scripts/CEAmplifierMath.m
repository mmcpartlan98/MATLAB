clc;
clear;
format compact;

% CALCULATION PARAMETERS
i_c = 0.01;
beta = 150;
beta_high = 250;
r_eac = 0;
vcc = 15;
r_l_cc = 10000;
r_ins2 = 750;


% FIRST STAGE CALCULATIONS
v_re = vcc * 0.10; % General practice: drop 15% of vcc across R_E
r_c = ((vcc-v_re)/2)/i_c;  % Split remaining voltage across Rc and Vce
r_loads1 = r_ins2;

% SECOND STAGE CALCULATIONS
i_c_cc = 0.02 - i_c;
i_b = i_c_cc/beta;
r_e = (vcc/2)/(i_b * (beta + 1));
i_b = i_c_cc/beta;
r_pi = 0.026/i_b;
r_out = 1/((1/r_e) + 1/((r_pi+r_c))/(beta + 1));

Av2_low = (r_ins2/(r_ins2 + r_c))*(((beta + 1)*r_e)/(r_pi+(beta+1)*r_e))*(r_l_cc/(r_l_cc+r_out));

Av2_high = (r_ins2/(r_ins2 + r_c))*(((beta_high + 1)*r_e)/(r_pi+(beta_high+1)*r_e))*(r_l_cc/(r_l_cc+r_out));

fprintf('R_E (Stage 2): %0.1f\n', r_e);


% FIRST STAGE CALCULATIONS
v_th = vcc/2;
i_b = i_c/beta;
i_e = i_b + i_c;
r_e = (v_re/i_e)/(1/beta + 1);
r_pi = 0.026/i_b;
r_edc = r_e - r_eac;

r_th = ((v_th - v_re - 0.7)/i_e) * beta;
Av_low = -(beta/(r_pi + (beta + 1)*r_eac)) * ...
    (r_c^(-1) + r_loads1^(-1))^(-1) * ...
    ((r_th^(-1) + (r_pi + (beta + 1)*r_eac)^(-1))^(-1)) / ...
    ((r_th^(-1) + (r_pi + (beta + 1)*r_eac)^(-1))^(-1) + 100);
%fprintf('Av (B = %0.2f, load = %0.2f): %f\n', beta, r_loads1, Av_low);

% r_l = 750;   % Uncomment to change r_l for testing

Av_high = -(beta_high/(r_pi + (beta_high + 1)*r_eac)) * ...
    (r_c^(-1) + r_loads1^(-1))^(-1) * ...
    ((r_th^(-1) + (r_pi + (beta_high + 1)*r_eac)^(-1))^(-1)) / ...
    ((r_th^(-1) + (r_pi + (beta_high + 1)*r_eac)^(-1))^(-1) + 100);
%fprintf('Av (B = %0.2f, load = %0.2f): %f\n', beta, r_loads1, Av_high);

r_in = 1/((1/r_th) + (1/(r_pi + (beta+1)*r_e)));

fprintf('R_C (Stage 1): %0.1f\n', r_c);
fprintf('R_E(AC, Stage 1): %0.1f\n', r_eac);
fprintf('R_E(DC, Stage 1): %0.1f\n', r_edc);
fprintf('R_B1/B2 (Stage 1): %0.1f\n', r_th*2);

fprintf('Total Av (low): %0.1f\n', Av_low*Av2_low);
fprintf('Total Av (high): %0.1f\n', Av_high*Av2_high);
fprintf('R_out: %0.1f\n', r_out);
fprintf('R_in: %0.1f\n', r_in);