clear;
clc;
format compact;

vcc = 15;
vce1 = 7.5;
ic1 = 0.0075;
ic2 = 0.0075;
rth = 15000;
vth = vcc/2;
rl = 10000;
rs = 0.0001; % Not required in circuit, but cannot be set to zero
beta = 250;
re1ac = 6;

ib1 = ic1 / beta;
ib2 = ic2 / beta;

re1 = (0.25 * vcc)/(ib1 * (beta + 1));
vce2 = vce1 - 0.25 * vcc - 0.7;

re2 = (vcc - vce2)/(ib2 * (beta + 1));
rc = (0.25 * vcc)/(ib2 + beta * ib1);

% rpi calculations
rpi1 = 0.026/ib1;
rpi2 = 0.026/ib2;

% Av gain calculations
req1 = (re2^(-1) + rl^(-1))^(-1);
topAv = - rc * (beta + 1) * req1;
bottomAv = rpi1 * (rc + rpi2 + 1);
Av = topAv/bottomAv;

% Calculate r_out based on equation for emitter-follower
rout = ((rpi2 + ((rth^(-1) + rc^(-1))^(-1))))/(beta + 1);
rout = (re2^(-1) + rout^(-1))^(-1);

% Calculated r_in based on equation for common-emitter
rin = (rth^(-1) + (rpi1 + (beta + 1) * re1)^(-1))^(-1);

% R_b1 and R_b2 calculations
ibias = vcc/(2 * rth);
curRatio = 1 + ibias/(ibias + ib1);
rb1 = rth * curRatio;
rb2 = (rth^(-1) - rb1^(-1))^(-1);

fprintf('Calculated gain: %0.2f\n', Av); 
fprintf('Calculated R_e1: %0.2f\n', re1); 
fprintf('Calculated R_e2: %0.2f\n', re2); 
fprintf('Calculated R_c: %0.2f\n', rc); 
fprintf('Calculated R_b1: %0.2f\n', rb1);
fprintf('Calculated R_b2: %0.2f\n', rb2);
fprintf('Calculated R_out: %0.2f\n', rout); 
fprintf('Calculated R_in: %0.2f\n', rin);