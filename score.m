function [scoreArray] = score(normalizedSpectraLocal, correctedSpectraScoreLocal, xScaleLocal)
[xGrid, yGrid, zGrid] = size(correctedSpectraScoreLocal);

% Construct score array
scoreArray = zeros(xGrid, yGrid);
scoreContributions = zeros(zGrid, 1);

lowerFingerprint = 1300;
lowerMidFingerprint = 2300;
upperMidFingerprint = 2500;
upperFingerprint = 3000;

% Generate polymer weighting array
weightArray = xScaleLocal;

% Less than 700 cm-1
lowWeight = 0.5;
% Between 700 & 2000 cm-1
midWeight = 1;
% Between 2000 & 3500 cm-1
highWeight = 1;
% Higher than 3500 cm-1
extremeWeight = 0.5;

for i = 1:length(weightArray)
    if (weightArray(i) < 1400)
        weightArray(i) = lowWeight;
    elseif (weightArray(i) < 2250)
        weightArray(i) = midWeight;
    elseif (weightArray(i) < 3700)
        weightArray(i) = highWeight;
    else
        weightArray(i) = extremeWeight;
    end
end

% Strip black background surrounding gold disk
% BG reference file
% SIMPLE FLAG
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BGReference = csvread('PendingSearches/BGReferences.txt');
[~, bgs] = size(BGReference);
bgs = bgs - 1;

[~, ~, ~, normalizedBG] = dptRead(BGReference, 1, bgs, 'n', 'Parsing background library');
normalizedBG = squeeze(normalizedBG);

for x = 1:xGrid
    for y = 1:yGrid
        
        clc;
        fprintf('Stripping background at cell %d of %d\n', ((x - 1) * yGrid + y), xGrid * yGrid);
        fprintf('%0.2f%% complete\n', (((x - 1) * yGrid + y)/(xGrid * yGrid)) * 100);
        
%         if cellIsBackground(correctedSpectraScoreLocal(x, y, :), correctedBG) == true
        if cellIsBackground(normalizedSpectraLocal(x, y, :), normalizedBG) == true
            correctedSpectraScoreLocal(x, y, :) = zeros(1, length(xScaleLocal));
        end
    end
end

for x = 1:xGrid
    for y = 1:yGrid
        % Calculate score for each spectrum
        % Find magnitude at each point of inflection
        fprintf('Scoring cell %d, %d\n', x, y);
        for z = 1:zGrid
            scoreContributions(z) = weightArray(z) * correctedSpectraScoreLocal(x, y, z);
        end
        deltaMag = diff(scoreContributions(searchX(xScaleLocal, lowerFingerprint):searchX(xScaleLocal, lowerMidFingerprint)));
        deltaX = diff(xScaleLocal(searchX(xScaleLocal, lowerFingerprint):searchX(xScaleLocal, lowerMidFingerprint)));
        
        deltaMag = [deltaMag; diff(scoreContributions(searchX(xScaleLocal, upperMidFingerprint):searchX(xScaleLocal, upperFingerprint)))];
        deltaX = [deltaX; diff(xScaleLocal(searchX(xScaleLocal, upperMidFingerprint):searchX(xScaleLocal, upperFingerprint)))];
        
        fingerprintRegionChange = abs(deltaMag ./ deltaX);
        scoreArray(x, y) = sum(fingerprintRegionChange) .* trapz(xScaleLocal(searchX(xScaleLocal, lowerFingerprint):searchX(xScaleLocal, upperFingerprint)), correctedSpectraScoreLocal(x, y, searchX(xScaleLocal, lowerFingerprint):searchX(xScaleLocal, upperFingerprint)));
    end
end
end