function [isBackground] = cellIsBackground(spectrum, correctedBG)
spectrum = squeeze(smoothdata(spectrum, 'gaussian', 7));
[bgs, ~] = size(correctedBG);
smallestError = Inf;
for index = 1:bgs
    % Attempt simple point-by-point subtraction-summation
    
    error = abs(spectrum - correctedBG(index, :)');
    errorSum = sum(error);
    
    if (errorSum < smallestError)
        smallestError = errorSum;
    end
end

if (smallestError < 35)
    isBackground = true;
else
    isBackground = false;
end
end