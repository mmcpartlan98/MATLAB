clear;
clc;
format compact;
close all;

ic = 0.001;
rin = 40000;
dgain = 1;
iref = 0.03;
vplus = 0;
vneg = -10;

beta = 100;
vt = 0.026;
vbe = 0.7;

ib = ic / beta;
rpi = vt / ib;
io = 2 * ic;

% Calculate diff amp values
re = (rin - 2 * rpi) / (2 * (beta + 1));
rc = 2 * dgain * (rpi + beta * re) * (1/beta);
rin = 2 * (rpi + (beta + 1) * re);

% Calculate widlar values
rref = (vplus - vneg - vbe) / iref;
rlimiter = (vt / io) * log(iref / io);

fprintf('Diff Amp Values\n');
fprintf('R_E: %0.1f\n', re);
fprintf('R_C: %0.1f\n', rc);
fprintf('R_in: %0.1f\n', rin);
fprintf('Current Source Values\n');
fprintf('R_limiter: %0.1f\n', rlimiter);
fprintf('R_ref: %0.1f\n', rref);