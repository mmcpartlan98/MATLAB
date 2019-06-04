clear;
clc;
format compact;
close all;

ilevel = 0.005;
rin = 40000;
dgain = 5.5;
iref = 0.03;
vplus = 10;
vneg = -10;
vplusCurrent = 0;
rload = 200;

beta = 100;
vt = 0.026;
vbe = 0.7;

% Calculate Differential Amplifier Values
for ic = 0.00001:0.000001:1
    ib = ic / beta;
    rpi = vt / ib;
    io = 2 * ic;
    
    % Calculate diff amp values
    re = (rin - 2 * rpi) / (2 * (beta + 1));
    rc = 2 * dgain * (rpi + beta * re) * (1/beta);
    rin = 2 * (rpi + (beta + 1) * re);
    
    % Calculate CE-Darlington Pair
    % ===========================================================
    
    % DC Transistor Parameters
    
    ied = 0.005;
    
    vred = 0.15 * vplus;
    vrcd = (vplus - vred) / 2;
    vced = vrcd;
    
    ibd = ied / (beta^2 + 2 * beta + 1);
    icd = ibd * (beta^2 + 2 * beta);
    rcd = vrcd / icd;
    red = vred / ied;
    
    avd = (ied * rcd) / (2 * vt);
    
    % ===================
    vq = rc * ic;
    
    if (vred + 2 * vbe) > vplus - rc * ic
        break;
    end
end

% Calculate widlar values
rref = (vplusCurrent - vneg - vbe) / iref;
rlimiter = (vt / io) * log(iref / io);
rlevel = (vt / ilevel) * log(iref / ilevel);

% Calculate level shifter approximation (must be fine-tuned in lab)
vcelevel = vplus - vrcd - vbe;
vrlevel = vplus - vbe - vcelevel;
rlevelbias = vrlevel / ilevel;

% Calculate common-collector output stage values
ieoutput = 0.02;
iboutput = ieoutput / beta;
rpioutput = vt / iboutput;

routput = ((vplus - vneg)/2)/ieoutput;

outputResistance = ((rpioutput / (beta + 1))^(-1) + (routput)^(-1))^(-1);

A = (beta + 1) * rload;
B = rpioutput + A;
avOutput = A / B;

% Print all values to the terminal
fprintf('Diff Amp Values\n');
fprintf('R_E: %0.1f\n', re);
fprintf('R_C: %0.1f\n', rc);
fprintf('R_in: %0.1f\n', rin);
fprintf('Av: %f\n', dgain);
fprintf('Current Source Values\n');
fprintf('R_lim_diff: %0.1f\n', rlimiter);
fprintf('R_ref: %0.1f\n', rref);

fprintf('\nDarlington Amplifier Properties\n');
fprintf('R_c: %f\n', rcd);
fprintf('R_e: %f\n', red);
fprintf('Av: %f\n', avd);

fprintf('\nLevel Shifter Properties\n');
fprintf('R_level: %f\n', rlevelbias);
fprintf('R_lim_lev: %0.1f\n', rlevel);

fprintf('\nOutput Stage Properties\n');
fprintf('R_e_output: %0.1f\n', routput);
fprintf('Output Resistance: %f\n', outputResistance);
fprintf('Av: %f\n', avOutput);

fprintf('\nTotal Amplifier Gain\n');
fprintf('Gain: %f\n', avOutput * avd * dgain);