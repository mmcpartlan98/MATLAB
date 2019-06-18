function [xScale, correctedSpectra, rawSpectra, normalizedSpectra] = dptRead(dptFile, xGrid, yGrid, suppressOutput, output)
% Returns xScale in ASCENDING order and rawSpectra flipped to MATCH xSCALE
windowSize = 50;
debug = 'n';
% Ascending order
xScale = flip(dptFile(:, 1));

% [~, columns] = size(dptFile);
columns = yGrid * xGrid + 1;
correctedSpectra = zeros(xGrid, yGrid, length(xScale));
normalizedSpectra = zeros(xGrid, yGrid, length(xScale));
rawSpectra = zeros(xGrid, yGrid, length(xScale));

rowIndex = xGrid;
colIndex = 1;

for fileColumn = columns:-1:2
    
    % Raw absorbance values (flipped to match ascending xScale)
    intensity = flip(dptFile(:, columns - fileColumn + 2));
    rawSpectra(rowIndex, colIndex, :) = intensity;
    
    tempArea = trapz(xScale, intensity);
    normalizedSpectra(rowIndex, colIndex, :) = intensity / tempArea;
    
    % Baseline adjusted absorbance
    baselineCorrected = msbackadj(xScale, intensity, 'StepSize', windowSize);
    % baselineCorrected = stripOffset(xScale, intensity);
    correctedSpectra(rowIndex, colIndex, :) = baselineCorrected;
    
    if suppressOutput ~= 'y'
        clc;
        fprintf('%s: %d\n=====================\n', output, fileColumn - 1);
        fprintf('%0.2f%% complete\n', (1 - (fileColumn - 2)/columns) * 100);
    end
    
    colIndex = colIndex + 1;
    if (colIndex > yGrid)
        rowIndex = rowIndex - 1;
        colIndex = 1;
    end
end
end