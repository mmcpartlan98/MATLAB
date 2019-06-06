function [scoreArray] = score(inflectionsFullScoreLocal, correctedSpectraScoreLocal, xScaleLocal)
[xGrid, yGrid, zGrid] = size(inflectionsFullScoreLocal);

% Construct score array
scoreArray = zeros(xGrid, yGrid);
scoreContributions = zeros(1, zGrid);

% Generate polymer weighting array
weightArray = xScaleLocal;

% Less than 700 cm-1
lowWeight = 0.05;
% Between 700 & 2000 cm-1
midWeight = 2;
% Between 2000 & 3500 cm-1
highWeight = 1;
% Higher than 3500 cm-1
extremeWeight = 0.05;

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

for x = 1:xGrid
    for y = 1:yGrid
        % Calculate score for each spectrum
        % Find magnitude at each point of inflection
        fprintf('Scoring cell %d, %d\n', x, y);
        for z = 1:zGrid
            if(inflectionsFullScoreLocal(x, y, z) == 0)
                magnitude = 0;
            else
                [searchResult, ~] = searchX(xScaleLocal, inflectionsFullScoreLocal(x, y, z));
                magnitude = correctedSpectraScoreLocal(x, y, searchResult);
            end
            scoreContributions(z) = weightArray(z) * magnitude;
        end
        scoreArray(x, y) = sum(abs(scoreContributions .* var(squeeze(correctedSpectraScoreLocal(x, y, :)) .* weightArray)));
    end
end
end