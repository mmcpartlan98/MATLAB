function [xScale, correctedSpectra, rawSpectra, inflectionsFull] = dptRead(dptFile, xGrid, yGrid, suppressOutput, output)
% Returns xScale in ASCENDING order and rawSpectra flipped to MATCH xSCALE
windowSize = 50;
debug = 'n';
% Ascending order
xScale = flip(dptFile(:, 1));

% [~, columns] = size(dptFile);
columns = yGrid * xGrid + 1;
correctedSpectra = zeros(xGrid, yGrid, length(xScale));
inflectionsFull = zeros(xGrid, yGrid, length(xScale));
rawSpectra = zeros(xGrid, yGrid, length(xScale));

rowIndex = xGrid;
colIndex = 1;

for fileColumn = columns:-1:2
    
    % Raw absorbance values (flipped to match ascending xScale)
    intensity = flip(dptFile(:, columns - fileColumn + 2));
    rawSpectra(rowIndex, colIndex, :) = intensity;
    
    % Baseline adjusted absorbance
    baselineCorrected = msbackadj(xScale, intensity, 'StepSize', windowSize);
    % baselineCorrected = stripOffset(xScale, intensity);
    correctedSpectra(rowIndex, colIndex, :) = baselineCorrected;
    
    % Calculate first derivative
    numDerivative = diff(intensity)./diff(xScale);
    
    % Calculate second derivative
    numDerivative2 = diff(numDerivative)./diff(xScale(1:length(xScale) - 1));
    
    if suppressOutput ~= 'y'
        clc;
        fprintf('%s: %d\n=====================\n', output, fileColumn - 1);
        fprintf('%0.2f%% complete\n', (1 - (fileColumn - 2)/columns) * 100);
    end
    
    if (sum(abs(numDerivative)) ~= 0)
        % Find zeros, flip to restore conventional spectral notation
        %  zeroCrossingsX = data_zeros(flip(xScale(1:length(xScale) - 2)), flip(numDerivative2))';
        zeroCrossingsX = data_zeros(flip(xScale(1:length(xScale) - 1)), flip(numDerivative))';
        
        % DEBUG MODE GRAPHING UTILITY
        if (debug == 'y')
            zeroCrossingsMagnitude = zeros(1, length(xScale));
            for magIndex = 1:xScale
                zeroCrossingsMagnitude(magIndex) = intensity(searchX(xScale, zeroCrossingsX(magIndex)));
            end
            figure;
            stem(zeroCrossingsX(1:length(zeroCrossingsX)), zeroCrossingsMagnitude(1:length(zeroCrossingsMagnitude)));
            hold on;
            plot(xScale, intensity);
        end
        
        % Pad with zeros to concatenate
        zeroCrossingsX = [flip(sort(zeroCrossingsX)') zeros(1, length(xScale) - length(zeroCrossingsX))];
    else
        zeroCrossingsX = zeros(1, length(xScale));
    end
    inflectionsFull(rowIndex, colIndex, :) = zeroCrossingsX;
    
    colIndex = colIndex + 1;
    if (colIndex > yGrid)
        rowIndex = rowIndex - 1;
        colIndex = 1;
    end
end
end