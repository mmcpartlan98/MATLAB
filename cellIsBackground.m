function [isBackground] = cellIsBackground(spectrum, number, backgroundPath)

bgs = 1;
spectrum = squeeze(smoothdata(spectrum, 'gaussian', 20));

% Assume only one background to be loaded for now
[BGXScale, ~, correctedBG, BGinflections] = dptRead(backgroundPath, 1, bgs, 'y');
BGinflections = squeeze(BGinflections);


for index = 1:bgs
    spectrumInflections = diff(spectrum)./diff(BGXScale);
    spectrumInflections = diff(spectrumInflections)./diff(BGXScale(1:length(BGXScale) - 1));
    
    if (sum(abs(spectrumInflections)) ~= 0)
        % Find zeros, flip to restore conventional spectral notation
        zeroCrossingsX = data_zeros(flip(BGXScale), flip(spectrumInflections))';
        % Pad with zeros to concatenate
        zeroCrossingsX = [flip(sort(zeroCrossingsX)') zeros(1, length(BGXScale) - length(zeroCrossingsX))]';
    else
        zeroCrossingsX = zeros(1, length(xScale));
    end
    
    % Compare inflection points for each
    errorSum = 0;
    for derIndex = 1:length(zeroCrossingsX)
        errorSum = errorSum + abs(zeroCrossingsX(derIndex) - BGinflections(derIndex));
    end
    
    if (errorSum > 100000)
        isBackground = true;
    else
        isBackground = false;
    end
    fprintf('Stripping background %d (Score: %d)\n', number, errorSum);
end
end