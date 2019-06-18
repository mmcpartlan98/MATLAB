function [isBackground] = cellIsBackground(spectrum, normalizedBG)
% Assumes that both spectrum and normalizedBG are ALREADY NORMALIZED

spectrum = squeeze(spectrum);
[bgs, ~] = size(normalizedBG);
smallestError = Inf;
for index = 1:bgs
    % Attempt simple point-by-point subtraction-summation
    
    error = abs(spectrum - normalizedBG(index, :)');
    errorSum = sum(error);
    
    if (errorSum < smallestError)
        smallestError = errorSum;
    end
end

fprintf('Smallest error: %0.4f\n', smallestError);

if (smallestError < 0.025)
    isBackground = true;
else
    isBackground = false;
end
end