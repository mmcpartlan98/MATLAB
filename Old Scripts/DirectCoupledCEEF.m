clear;
clc;
format compact;

vcc = 15;
ie1 = 0.0075;
ie2 = 0.0075;
ibias = 0.005;
rin = 600;
rload = 10000;

beta = 250;
vbe = 0.7;

vce1 = vcc / 2; % VCE should be about half of total available voltage supply
vce2 = vcc / 2; % VCE should be about half of total available voltage supply
vre1 = vcc / 4;
vrc = vcc / 4;
ib1 = ie1 / (1 + beta);
ib2 = ie2 / (1 + beta);
ic1 = beta * ib1;
vb1 = vre1 + vbe;
vre2 = vcc - vrc - vbe;

re1 = vre1 / ie1;
re2 = (vcc - vrc - vbe) / ie1;
rc = vrc / (ic1 + ib2);

% Rb2 is bottom, Rb1 is top
rb1 = (vcc - vre1 - vbe) / ibias;
rb2 = (vre1 + vbe) / ibias;

% AC emitter resistors
re1ac = 0;
re2ac = re2;

% Calculate AC parameters
rpi1 = 0.026 / ib1;
rpi2 = 0.026 / ib2;

% Gain calculations
s1RL = rpi2 + (1 + beta) * (re2^(-1) + rload^(-1))^(-1);
A = - beta * (rc^(-1) + (s1RL)^(-1))^(-1);
B = rpi1 + re1ac * (beta + 1);
Av1 = A / B;

A = (beta + 1) * ((re2ac)^(-1) + (rload)^(-1))^(-1);
B = rpi2 + A;
Av2 = A / B;

Avtotal = Av1 * Av2;

% Calculate input and output resistance
outputResistance = ((rpi2 / (beta + 1))^(-1) + (re2)^(-1))^(-1);
inputResistance = ((((rb1)^(-1) + (rb2)^(-1))^(-1))^(-1) + (rpi1 + (beta + 1) * re1)^(-1))^(-1);

fprintf('R_E1: %0.1f\n', re1);
fprintf('R_E2: %0.1f\n', re2);
fprintf('R_C: %0.1f\n', rc);
fprintf('R_B1: %0.1f\n', rb1);
fprintf('R_B2: %0.1f\n', rb2);
fprintf('Amplifier Properties\n');
fprintf('R_O: %0.1f\n', outputResistance);
fprintf('R_IN: %0.1f\n', inputResistance);
fprintf('Av_stage1) (B = %0.2f, load = %0.2f): %f\n', beta, rload, Av1);
fprintf('Av_stage2 (B = %0.2f, load = %0.2f): %f\n', beta, rload, Av2);
fprintf('Av_total (B = %0.2f, load = %0.2f): %f\n', beta, rload, Av1 * Av2);