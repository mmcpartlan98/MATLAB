clear;
clc;
format compact;
close all;

filePath = '/Users/mattmcpartlan/Desktop/';
prompt = 'File name on Desktop (Dont include extensions): ';
fileName = input(prompt, 's');
readPath = [filePath  fileName  '.dpt'];

% filePath = 'C:\Users\PC\iCloudDrive\Desktop\UHRMap135.dpt';

% Set significance cutoff for background noise
lowerSignificanceCutoff = 0;

[xScale, correctedSpectra, rawSpectra, inflectionsFull] = dptRead(readPath, 25, 25);

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

figure;
hold on;

for particle = 1:numberOfParticles
%    particleSpectra(:, particle + 1) = generateParticleSpectrum(clusters, particle, rawSpectra, xScale);
    particleSpectra(:, particle + 1) = generateParticleSpectrum(clusters, particle, correctedSpectra, xScale);
    plot(xScale, particleSpectra(:, particle + 1));
    %set(gca, 'XDir','reverse');
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