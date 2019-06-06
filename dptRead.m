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

for fileColumn = columns:-1:2
    % Raw absorbance values (flipped to match ascending xScale)
    intensity = flip(dptFile(:, columns - fileColumn + 2));
    rawSpectra(xGrid - floor((fileColumn - 2)/xGrid), mod(fileColumn - 2, xGrid) + 1, :) = intensity;

    % Baseline adjusted absorbance
    baselineCorrected = msbackadj(xScale, intensity, 'StepSize', windowSize);
    correctedSpectra(xGrid - floor((fileColumn - 2)/xGrid), mod(fileColumn - 2, xGrid) + 1, :) = baselineCorrected;
    
    % Calculate first derivative
    numDerivative = diff(intensity)./diff(xScale);
    
    % Calculate second derivative
    numDerivative2 = diff(numDerivative)./diff(xScale(1:length(xScale) - 1));
    
    fprintf('Parsing cell: %d\n =====================\n', fileColumn);
    
    if (sum(abs(numDerivative)) ~= 0)
        % Find zeros, flip to restore conventional spectral notation
        zeroCrossingsX = data_zeros(flip(xScale), flip(numDerivative2))';
        % Pad with zeros to concatenate
        zeroCrossingsX = [flip(sort(zeroCrossingsX)') zeros(1, length(xScale) - length(zeroCrossingsX))];
    else
        zeroCrossingsX = zeros(1, length(xScale));
    end
    inflectionsFull(floor((fileColumn - 2)/xGrid) + 1, mod(fileColumn - 2, xGrid) + 1, :) = zeroCrossingsX;
end
end