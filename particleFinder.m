clear;
clc;
format compact;
close all;

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

% Set significance cutoff for background noise
lowerSignificanceCutoff = 0;

[xScale, correctedSpectra, rawSpectra, normalizedFull] = dptRead(dptFile, rowLength, colLength, 'n', 'Parsing spectra map');

scArry = score(normalizedFull, correctedSpectra, xScale);

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

clusters = clusterSpectra(normalizedFull, 'n', scArry);

% Generate spectra for all each particle
numberOfParticles = max(max(clusters));
particleSpectra = zeros(length(xScale), numberOfParticles + 1);
particleSpectra(:, 1) = flip(xScale);

for particle = 1:numberOfParticles
    % figure;
    particleSpectra(:, particle + 1) = flip(generateParticleSpectrum(clusters, particle, rawSpectra, xScale));
    %    particleSpectra(:, particle + 1) = generateParticleSpectrum(clusters, particle, correctedSpectra, xScale);
    plot(xScale, flip(particleSpectra(:, particle + 1)));
    hold on;
    set(gca, 'XDir','reverse');
    titleString = sprintf('Particle %d Average Spectrum', particle);
    title(titleString);
end

writePath = ['PendingSearches/' fileName 'Clustered' '.csv'];
writematrix(particleSpectra, writePath);

% Generare figures below
rawScoreFigure = prettyBar3(scArry);
clusterFigure = prettyBar3(clusters);

prompt = input('Press return to label backgrounds (or "d" to exit): ', 's');
if isempty(prompt)
    close all;
    rawScoreFigure = prettyBar3(scArry);
    
    % SIMPLE FLAG
    % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    backgroundPath = csvread('PendingSearches/BGReferences.txt');
    [~, bgs] = size(backgroundPath);
    bgs = bgs - 1;
    [bgXScale, ~, rawBG, ~] = dptRead(backgroundPath, 1, bgs, 'n', 'Parsing library data');
    selectedBGSpectra = [flip(bgXScale) flip(squeeze(rawBG)')];
    
    prevBackup = csvread('LibraryBackups/BGReferencesIndex.txt');
    writePath = ['LibraryBackups/BGReferences' num2str(prevBackup) '.txt'];
    writematrix(selectedBGSpectra, writePath);
    writematrix(prevBackup + 1, 'LibraryBackups/BGReferencesIndex.txt');
    
    modifiedSpectraFlag = false;
    
    while isempty(prompt)
        clc;
        fprintf('Use cursor to select data to label as background.\n');
        rawScoreFigure = prettyBar3(scArry);
        figure(rawScoreFigure);
        view(2);
        bgRow = Inf;
        bgCol = Inf;
        
        % BUG IF USER PRESSES RETURN WITHOUT SELECTING A POINT
        while (bgRow > rowLength || bgCol > colLength)
            [bgCol, bgRow] = ginput(1);
            bgRow = round(bgRow);
            bgCol = round(bgCol);
            if (bgRow > rowLength || bgCol > colLength)
                fprintf('Position %d, %d is invalid.\n', bgRow, bgCol);
            end
        end
        
        clf(rawScoreFigure);
        
        plot(xScale, squeeze(rawSpectra(bgRow, bgCol, :)), 'r');
        set(gca, 'XDir','reverse');
        
        outputString = sprintf('Confirm (y/n) that position %d, %d is background: ', bgRow, bgCol);
        prompt = input(outputString, 's');
        if (prompt == 'y')
            scArry(bgRow, bgCol) = 0;
            modifiedSpectraFlag = true;
            selectedBGSpectra = [selectedBGSpectra flip(squeeze(rawSpectra(bgRow, bgCol, :)))]; %#ok<AGROW>
        end
        prompt = input('Press return to enter another background (or enter "d"): ', 's');
    end
    
    [~, entries] = size(selectedBGSpectra);
    outputString = sprintf('Save %d new spectra as background references (y/n): ', (entries - bgs - 1));
    prompt = input(outputString, 's');
    if (modifiedSpectraFlag == true && prompt == 'y')
        writePath = 'PendingSearches/BGReferences.txt';
        writematrix(selectedBGSpectra, writePath);
        writePath = 'PendingSearches/BGReferencesData.txt';
        writematrix(entries, writePath);
    end
end

prompt = input('Would you like to export coordinates? (y/n): ', 's');

if (prompt == 'y')
    OVRCoords = dlmread(['/Users/mattmcpartlan/Desktop/' fileName '.ooic'],' ');
    
    xStart = min(OVRCoords(:, 1));
    xRange = max(OVRCoords(:, 1)) - xStart;
    xStep = xRange / colLength;
    yStart = min(OVRCoords(:, 2));
    yRange = max(OVRCoords(:, 2)) - yStart;
    yStep = yRange / rowLength;
    
    % Each particle gets two adacent columns (x, y). Odd columns are x
    % values, even columns are y values. Each particle's minimum and
    % maximum corner coordinates are recorded
    linearCoordinateString = zeros(2, numberOfParticles * 2);
    
    for p = 1:2:numberOfParticles*2
        localMinX = Inf;
        localMinY = Inf;
        localMaxX = 0;
        localMaxY = 0;
        for i = 1:rowLength
            for e = 1:colLength
                if clusters(i, e) == p
                    if (i < localMinX)
                        localMinX = i;
                    end
                    
                    if (i > localMaxX)
                        localMaxX = i;
                    end
                    
                    if (e < localMinY)
                        localMinY = e;
                    end
                    
                    if (e > localMaxY)
                        localMaxY = e;
                    end
                end
            end
        end
        localMinX = localMinX * xStep;
        localMinY = localMinY * yStep;
        localMaxX = localMaxX * xStep;
        localMaxY = localMaxY * yStep;
        
        linearCoordinateString(1, p) = localMinX;
        linearCoordinateString(1, p + 1) = localMinY;
        linearCoordinateString(2, p) = localMaxX;
        linearCoordinateString(2, p + 1) = localMaxY;
    end
end