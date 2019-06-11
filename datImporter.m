clear;
clc;
format compact;
close all;

% Uncomment for MAC
input2 = csvread('/Users/mattmcpartlan/Desktop/sample135.dpt');

% Uncomment for WINDOWS
% input2 = csvread('C:\Users\PC\iCloudDrive\Desktop\sample135.dpt');

% SET BACKGROUND PLOT (search for closest)
bgPlot = 10;
percentWeighted = 0.05;
% Comparison mode "WEIGHTEDPEAKS" is currently questionable
comparisonMode = "weightedPeaks";
% comparisonMode = "else";

stopPlot = 26;
startPlot = 2;
windowSize = 100;
xScale = flip(input2(:, 1));

figure;
hold on;
for i = startPlot:stopPlot
    plot(input2(:, 1), input2(:, i));
    % input2(:, i) = sgolayfilt(input2(:, i), 4, 11);
end
set(gca, 'XDir','reverse')

% Create empty array of 2nd derivative zero crossings
mapCrossings = zeros((stopPlot - startPlot + 1), length(xScale));

% Create adjusted array
adjustedIntensities = zeros((stopPlot - startPlot + 1), length(xScale));

figure;
hold on;
for i = startPlot:stopPlot
    % Raw absorbance values
    intensities = flip(input2(:, i));
    
    % Baseline adjusted absorbance
    baselineCorrected = flip(msbackadj(xScale, intensities, 'StepSize', windowSize));
    adjustedIntensities(i - 1, :) = baselineCorrected;
    plot(input2(:, 1), baselineCorrected);
    set(gca, 'XDir','reverse')
    
    % Calculate first derivative
    numDerivative = diff(intensities)./diff(xScale);
    
    % Calculate second derivative
    numDerivative2 = diff(numDerivative)./diff(xScale(1:length(xScale) - 1));
    
    % Find zeros
    zeroCrossingsX = data_zeros(flip(xScale), flip(numDerivative2))';
    % plot(xScale(3:length(xScale)), numDerivative2);
    % plot(xScale(3:length(xScale)), zeros(length(xScale) - 2));
    % set(gca, 'XDir','reverse')
    
    zeroCrossingsX = [flip(sort(zeroCrossingsX)') zeros(1, length(xScale) - length(zeroCrossingsX))];
    
    mapCrossings((i - startPlot + 1), :) = zeroCrossingsX;
end

% Import of define background spectrum. ASSUME bgPlot spectrum is desired
% spectrum
backgroundSpectrum = mapCrossings(bgPlot, :);
backgroundIntensities = adjustedIntensities(bgPlot, :);

% Measure hit quality
hitQuality = zeros(1, stopPlot - 1);

if (comparisonMode == "weightedPeaks")
    for i = 1:(stopPlot - 1)
        % At this point, mapCrossings represents the DIFFERENCE between
        % the background spectrum and EACH sample spectrum
        mapCrossings(i, :) = mapCrossings(i, :) - backgroundSpectrum;
        for e = 1:length(xScale)
            xCord = searchX(xScale, backgroundSpectrum(e));
            if (percentWeighted == 0)
                hitQuality(i) = hitQuality(i) + abs(mapCrossings(i, e));
            else
                hitQuality(i) = hitQuality(i) + abs(mapCrossings(i, e)) + abs(mapCrossings(i, e) / (percentWeighted*(adjustedIntensities(i, xCord) - backgroundIntensities(xCord))));
            end
        end
    end
    % Find best hit
    bestHit = Inf;
    bestHitIndex = 0;
    % Start at two because of above assumption
    for i = 2:(stopPlot - 1)
        if (hitQuality(i) < bestHit && i ~= bgPlot)
            bestHit = hitQuality(i);
            bestHitIndex = i;
        end
    end
else
    for i = 1:(stopPlot - 1)
        % At this point, mapCrossings represents the DIFFERENCE between
        % the background spectrum and EACH sample spectrum
        mapCrossings(i, :) = mapCrossings(i, :) - backgroundSpectrum;
        for e = 1:length(xScale)
            
            xCord = searchX(xScale, backgroundSpectrum(e));
            hitQuality(i) = hitQuality(i) + abs(mapCrossings(i, e));
        end
    end
    % Find best hit
    bestHit = Inf;
    bestHitIndex = 0;
    % Start at two because of above assumption
    for i = 2:(stopPlot - 1)
        if (hitQuality(i) < bestHit && i ~= bgPlot)
            bestHit = hitQuality(i);
            bestHitIndex = i;
        end
    end
end



disp(bestHit);
disp(bestHitIndex);
figure;
hold on;
plot(flip(xScale), adjustedIntensities(bgPlot, :), 'k');
plot(flip(xScale), adjustedIntensities(bestHitIndex, :), 'r');
set(gca, 'XDir','reverse');

figure;
hold on;
plot(xScale, flip(input2(:, bgPlot + 1)), 'k');
plot(xScale, flip(input2(:, bestHitIndex + 1)), 'r');
set(gca, 'XDir','reverse');