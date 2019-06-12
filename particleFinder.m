clear;
clc;
format compact;
close all;

% bgs is number of spectra in the library of backgrounds
filePath = '/Users/mattmcpartlan/Desktop/PendingSearches/BGReferencesData.txt';
bgs = csvread(filePath);

filePath = '/Users/mattmcpartlan/Desktop/';
prompt = 'File name on Desktop (Dont include extensions): ';
fileName = input(prompt, 's');
readPath = [filePath fileName '.dpt'];

isSquare = input('Press return if spectral map is square: ', 's');

if (~isempty(isSquare))
    rowLength = input('Row length: ');
    colLength = input('Number of columns: ');
    dptFile = csvread(readPath);
else
    dptFile = csvread(readPath);
    [~, dptSize] = size(dptFile);
    rowLength = sqrt(dptSize - 1);
    colLength = rowLength;
end


% rowLength = 60;
% colLength = 60;

% readPath = 'C:\Users\PC\iCloudDrive\Desktop\UHRsample140.dpt';

% Set significance cutoff for background noise
lowerSignificanceCutoff = 0;

[xScale, correctedSpectra, rawSpectra, inflectionsFull] = dptRead(dptFile, rowLength, colLength, 'n', 'Parsing spectra map');

scArry = score(inflectionsFull, correctedSpectra, xScale, bgs);

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

for i = 1:numel(b)
    %# get the ZData matrix of the current group
    Z = get(b(i), 'ZData');

    %# row-indices of Z matrix. Columns correspond to each rectangular bar
    rowsInd = reshape(1:size(Z,1), 6,[]);

    %# find bars with zero height
    barsIdx = all([Z(2:6:end, 2:3) Z(3:6:end, 2:3)] == 0, 2);

    %# replace their values with NaN for those bars
    Z(rowsInd(:, barsIdx),:) = NaN;

    %# update the ZData
    set(b(i), 'ZData', Z);
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

for i = 1:numel(c)
    %# get the ZData matrix of the current group
    Z = get(c(i), 'ZData');

    %# row-indices of Z matrix. Columns correspond to each rectangular bar
    rowsInd = reshape(1:size(Z,1), 6,[]);

    %# find bars with zero height
    barsIdx = all([Z(2:6:end, 2:3) Z(3:6:end, 2:3)] == 0, 2);

    %# replace their values with NaN for those bars
    Z(rowsInd(:, barsIdx),:) = NaN;

    %# update the ZData
    set(c(i), 'ZData', Z);
end