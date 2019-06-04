function [xScale, correctedSpectra, rawSpectra, inflectionsFull] = dptRead(filename, xGrid, yGrid)
% Returns xScale in ASCENDING order and rawSpectra flipped to MATCH xSCALE
dptFile = csvread(filename);
windowSize = 50;

% Ascending order
xScale = flip(dptFile(:, 1));

[~, columns] = size(dptFile);
correctedSpectra = zeros(xGrid, yGrid, length(xScale));
inflectionsFull = zeros(xGrid, yGrid, length(xScale));
rawSpectra = zeros(xGrid, yGrid, length(xScale));

fileColumn = 2;
xPos = 1;
yPos = 1;

while (fileColumn <= columns)    
    % Raw absorbance values (flipped to match ascending xScale)
    intensity = flip(dptFile(:, fileColumn));
    rawSpectra(xPos, yPos, :) = intensity;
    
    % Baseline adjusted absorbance
    baselineCorrected = flip(msbackadj(xScale, intensity, 'StepSize', windowSize));
    correctedSpectra(xPos, yPos, :) = baselineCorrected;
    
    % Calculate first derivative
    numDerivative = diff(intensity)./diff(xScale);
    
    % Calculate second derivative
    numDerivative2 = diff(numDerivative)./diff(xScale(1:length(xScale) - 1));
    
    fprintf('xPos: %d yPos: %d column: %d\n =====================\n', xPos, yPos,fileColumn);
    
    if (sum(abs(numDerivative)) ~= 0)
        % Find zeros, flip to restore conventional spectral notation
        zeroCrossingsX = data_zeros(flip(xScale), flip(numDerivative2))';
        % Pad with zeros to concatenate
        zeroCrossingsX = [flip(sort(zeroCrossingsX)') zeros(1, length(xScale) - length(zeroCrossingsX))];
    else
        zeroCrossingsX = zeros(1, length(xScale));
    end
    
    inflectionsFull(xPos, yPos, :) = zeroCrossingsX;
    
    yPos = yPos + 1;
    fileColumn = fileColumn + 1;
    if (mod(fileColumn - 2, xGrid) == 0)
        yPos = 1;
        xPos = xPos + 1;
    end
end
end