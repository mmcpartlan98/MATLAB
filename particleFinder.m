clear;
clc;
format compact;
close all;

filePath = '/Users/mattmcpartlan/Desktop/';
prompt = 'File name on Desktop (Dont include extensions): ';
fileName = 'OVRsample143';
% fileName = input(prompt, 's');
readPath = [filePath  fileName  '.dpt'];

% rowLength = input('Row length: ');
% colLength = input('Number of columns: ');

rowLength = 25;
colLength = 25;

% readPath = 'C:\Users\PC\iCloudDrive\Desktop\UHRsample140.dpt';

% Set significance cutoff for background noise
lowerSignificanceCutoff = 0;

[xScale, correctedSpectra, rawSpectra, inflectionsFull] = dptRead(readPath, rowLength, colLength, 'n');

scArry = score(inflectionsFull, correctedSpectra, xScale);

[rows, cols] = size(scArry);

maximum = max(max(scArry));

for row = 1:rows
    for col = 1:cols
        if (scArry(row, col) < lowerSignificanceCutoff * maximum)
            scArry(row, col) = 0;
        end
    end
end


minimum = min(min(scArry(scArry > 0)));
[xMin,yMin] = find(scArry == minimum);
[xMax,yMax] = find(scArry == maximum);

clusters = clusterSpectra(inflectionsFull, 'n', scArry);

% Generate spectra for all each particle
numberOfParticles = max(max(clusters));
particleSpectra = zeros(length(xScale), numberOfParticles + 1);
particleSpectra(:, 1) = flip(xScale);

for particle = 1:numberOfParticles
    figure;
    particleSpectra(:, particle + 1) = flip(generateParticleSpectrum(clusters, particle, rawSpectra, xScale));
%    particleSpectra(:, particle + 1) = generateParticleSpectrum(clusters, particle, correctedSpectra, xScale);
    plot(xScale, flip(particleSpectra(:, particle + 1)));
    set(gca, 'XDir','reverse');
    titleString = sprintf('Particle %d Average Spectrum', particle);
    title(titleString);
end

writePath = [filePath 'PendingSearches/' fileName 'Clustered' '.csv'];
writematrix(particleSpectra, writePath);

% Generare figures below
figure;
b = bar3(scArry);

for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    if (b(k) == 0)
        b(k).FaceColor = 'none';
    else
        b(k).FaceColor = 'interp';
    end
end

figure;
c = bar3(clusters);

for k = 1:length(c)
    zdata = c(k).ZData;
    c(k).CData = zdata;
    if (c(k) == 0)
        c(k).FaceColor = 'none';
    else
        c(k).FaceColor = 'interp';
    end
end