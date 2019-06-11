function [isBackground] = cellIsBackground(spectrum, number, backgroundPath)
debug = 'n';
bgs = 1;
spectrum = squeeze(smoothdata(spectrum, 'gaussian', 7));

% Assume only one background to be loaded for now
[BGXScale, ~, correctedBG, BGinflections] = dptRead(backgroundPath, 1, bgs, 'y');
BGinflections = squeeze(BGinflections);


for index = 1:bgs
    spectrumInflections = diff(spectrum)./diff(BGXScale);
    % spectrumInflections = diff(spectrumInflections)./diff(BGXScale(1:length(BGXScale) - 1));
    
    if (sum(abs(spectrumInflections)) ~= 0)
        % Find zeros, flip to restore conventional spectral notation
        zeroCrossingsXLocal = data_zeros(flip(BGXScale), flip(spectrumInflections))';
        % Pad with zeros to concatenate
        zeroCrossingsXLocal = [flip(sort(zeroCrossingsXLocal)') zeros(1, length(BGXScale) - length(zeroCrossingsXLocal))]';
    else
        zeroCrossingsXLocal = zeros(1, length(xScale));
    end
    
    % DEBUG MODE INFLECTION POINT GRAPHING
    if (debug == 'y')
        zeroCrossingsMagnitude = zeros(length(BGXScale), 1);
        for magIndex = 1:BGXScale
            zeroCrossingsMagnitude(magIndex) = spectrum(searchX(BGXScale, zeroCrossingsXLocal(magIndex)));
        end
        plot(BGXScale, spectrum);
        hold on;
        stem(zeroCrossingsXLocal, zeroCrossingsMagnitude);
        plot(BGXScale(1:length(BGXScale) - 1), spectrumInflections);
        hold on;
        
        figure;
        correctedBG = squeeze(correctedBG);
        plot(BGXScale, correctedBG);
        hold on;
        for magIndex = 1:BGXScale
            zeroCrossingsMagnitude(magIndex) = correctedBG(searchX(BGXScale, BGinflections(magIndex)));
        end
        stem(BGinflections, zeroCrossingsMagnitude);
    end
    
    % Compare inflection points for each
    errorSum = 0;
    for derIndex = 1:length(zeroCrossingsXLocal)
        errorSum = errorSum + abs(zeroCrossingsXLocal(derIndex) - BGinflections(derIndex));
    end
    
    % Attempt simple point-by-point subtraction-summation
    
    errorSum = 0;
    for derIndex = 1:length(zeroCrossingsXLocal)
        errorSum = errorSum + abs(zeroCrossingsXLocal(derIndex) - BGinflections(derIndex));
    end
    
    if (errorSum > 100000)
        isBackground = true;
    else
        isBackground = false;
    end
    fprintf('Stripping background %d (Score: %d)\n', number, errorSum);
end
end