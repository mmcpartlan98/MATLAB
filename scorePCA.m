function [scoreArray] = scorePCA(correctedSpectraLocal, xScaleLocal)
[xGrid, yGrid, ~] = size(correctedSpectraLocal);

% Construct score array
scoreArray = zeros(xGrid, yGrid);

% Generate polymer weighting array
weightArray = xScaleLocal;

% Less than 700 cm-1
lowWeight = 0.05;
% Between 700 & 1500 cm-1
midWeight = 1.5;
% Between 1500 & 3500 cm-1
highWeight = 1;
% Higher than 3500 cm-1
extremeWeight = 0.01;

for i = 1:length(weightArray)
    if (weightArray(i) < 700)
        weightArray(i) = lowWeight;
    elseif (weightArray(i) < 1500)
        weightArray(i) = midWeight;
    elseif (weightArray(i) < 3500)
        weightArray(i) = highWeight;
    else
        weightArray(i) = extremeWeight;
    end
end
weightArray = flip(weightArray);
weightArray = ones(1, length(xScaleLocal));

for x = 1:xGrid
    for y = 1:yGrid
        if (sum(correctedSpectraLocal(x, y, :)) == 0)
            correctedSpectraLocal(x, y, :) = correctedSpectraLocal(x, y - 1, :);
        end
        % Calculate score for each spectrum, scale by weighting array, and
        % use the first PCA coefficient as the score
        fprintf('Scoring cell %d, %d\n', x, y);
        pcaArray = [squeeze(correctedSpectraLocal(x, y, :))];
        pcaArray = var(pcaArray);
        scoreArray(x, y) = sum(pcaArray, 'all');
    end
end
end