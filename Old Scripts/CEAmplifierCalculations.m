clear;
clc;
format compact;

vcc = 20;
ic = 0.010;
beta = 50;
reac = 2;
rs = 100;
rload = 500;
ibias = 0.001;
vbe = 0.7;

% DC Transistor Parameters
vre = 0.15 * vcc;
vrc = (vcc - vre) / 2;
vce = vrc;

ib = ic / beta;
ie = ib * (beta + 1);
rc = vrc / ic;
re = vre / ie;
gm = beta * (ib / 0.026);
rpi = 0.026/ib;

% Rb2 is bottom, Rb1 is top
rb1 = (vcc - vre - vbe) / ibias;
rb2 = (vre + vbe) / ibias;

% Calculate input and output resistance
outputResistance = rc;
inputResistance = ((((rb1)^(-1) + (rb2)^(-1))^(-1))^(-1) + (rpi + (beta + 1) * re )^(-1))^(-1);
rin = inputResistance;

Av = (-gm * ((rc)^(-1) + (rload)^(-1))^(-1) * (rpi) * rin) / ((rpi + (beta + 1) * reac) * (rin + rs));
fprintf('Av (B = %0.2f, load = %0.2f): %f\n', beta, rload, Av);

beta = 200;
rload = 750;

ib = ic / beta;
gm = beta * (ib / 0.026);
ie = ib * (beta + 1);
rpi = 0.026/ib;

Av = (-gm * ((rc)^(-1) + (rload)^(-1))^(-1) * (rpi) * rin) / ((rpi + (beta + 1) * reac) * (rin + rs));
fprintf('Av (B = %0.2f, load = %0.2f): %f\n', beta, rload, Av);

fprintf('R_EDC: %0.1f\n', (re - reac));
fprintf('R_EAC: %0.1f\n', reac);
fprintf('R_C: %0.1f\n', rc);
fprintf('R_B1: %0.1f\n', rb1);
fprintf('R_B2: %0.1f\n', rb2);
fprintf('Amplifier Properties\n');
fprintf('R_O: %0.1f\n', outputResistance);
fprintf('R_IN: %0.1f\n', inputResistance);