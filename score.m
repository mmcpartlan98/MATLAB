function [scoreArray] = score(inflectionsFullScoreLocal, correctedSpectraScoreLocal, xScaleLocal)
[xGrid, yGrid, zGrid] = size(inflectionsFullScoreLocal);

% Construct score array
scoreArray = zeros(xGrid, yGrid);
scoreContributions = zeros(1, zGrid);

% Reference inflections: assume zero
referenceInflections = zeros(1, zGrid);

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

for x = 1:xGrid
    for y = 1:yGrid
        % Calculate score for each spectrum
        % Find magnitude at each point of inflection
        fprintf('Scoring cell %d, %d\n', x, y);
        for z = 1:zGrid
            if(inflectionsFullScoreLocal(x, y, z) == 0)
                magnitude = 0;
            else
                [~, searchResult] = searchX(xScaleLocal, inflectionsFullScoreLocal(x, y, z));
                magnitude = correctedSpectraScoreLocal(x, y, searchResult);
            end
            scoreContributions(z) = weightArray(z) * magnitude;
        end
        scoreArray(x, y) = sum(abs(scoreContributions));
    end
end
end