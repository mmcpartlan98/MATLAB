clear;
clc;
format compact;

% Use this script to generate a file of background spectra
cutoff = 0.025;
% radius = 22;
radius = 0;

filePath = '/Users/mattmcpartlan/Desktop/';
fileName = input('File name on Desktop (Dont include extensions): ', 's');

readPath = csvread([filePath  fileName  '.dpt']);

isSquare = input('Press return if spectral map is square: ', 's');

if (~isempty(isSquare))
    rowLength = input('Row length: ');
    colLength = input('Number of columns: ');
else
    [~, readSize] = size(readPath);
    rowLength = sqrt(readSize - 1);
    colLength = rowLength;
end

backgroundPath = csvread('PendingSearches/BGReferencesSIMPLE.txt');
[~, bgs] = size(backgroundPath);
bgs = bgs - 1;

[xScale, ~, rawSpectra, normalizedSpectra] = dptRead(readPath, rowLength, colLength, 'n', 'Parsing map spectrum');



scoreArray = zeros(rowLength, colLength);
% Assume only one background to be loaded for now
[~, ~, rawBG, normalizedBG] = dptRead(backgroundPath, 1, bgs, 'n', 'Parsing library data');
normalizedBG = squeeze(normalizedBG);

for i = 1:rowLength
    for e = 1:colLength
        spectrum = squeeze(normalizedSpectra(i, e, :));
        clc;
        fprintf('Stripping background: %0.2f%% complete\n', (((i - 1) * colLength + e)/(rowLength * colLength)) * 100);
        smallestError = Inf;
        for index = 1:bgs
            
            % Attempt simple point-by-point subtraction-summation
            
            error = abs(spectrum - normalizedBG(index, :)');
            errorSum = sum(error);
            
            if (errorSum < smallestError)
                smallestError = errorSum;
            end
        end
        scoreArray(i, e) = smallestError;
    end
end

spectra = 2;
spectraToWrite(:, 1) = flip(xScale);
for i = 1:rowLength
    for e = 1:colLength
        
        distanceFromCenter = sqrt((rowLength/2 - i)^2 + (colLength/2 - e)^2);
        
        if (scoreArray(i, e) < cutoff && distanceFromCenter > radius)
            spectraToWrite(:, spectra) = flip(squeeze(rawSpectra(i, e, :)));
            spectra = spectra + 1;
            scoreArray(i, e) = 0;
        end
    end
end

% Filter out repeats and export new spectra to background library
writePath = 'PendingSearches/BGReferences.txt';
unfilteredLibrary = [spectraToWrite flip(squeeze(rawBG)')];
[~, numberOfSpectra] = size(unfilteredLibrary);
exportLibrary(:, 1) = unfilteredLibrary(:, 1);
exportIndex = 2;

for i = 2:numberOfSpectra
    clc;
    fprintf('Removing duplicate backgrounds: %0.2f%%\n', (i/numberOfSpectra)*100);
    isRepeat = 0;
    for e = i:numberOfSpectra
        test = squeeze(unfilteredLibrary(:, i)) - squeeze(unfilteredLibrary(:, e));
        if (sum(test) == 0 && i ~= e)
            isRepeat = 1;
        end
    end
    if (isRepeat == 0)
        exportLibrary(:, exportIndex) = unfilteredLibrary(:, i);
        exportIndex = exportIndex + 1;
    end
end

% Compare previous library and new library to find new spectra
newSpectra(:, 1) = zeros(length(xScale), 1);
newSpectraExport(:, 1) = exportLibrary(:, 1);
previousLibrary = flip(squeeze(rawBG)');
newSpectraIndex = 1;
newSpectraExportIndex = 2;
[~, numberOfSpectra] = size(exportLibrary);
[~, numberOfPreviousSpectra] = size(previousLibrary);

for i = 2:numberOfSpectra
    clc;
    fprintf('Finding new spectra: %0.2f%%\n', (i/numberOfSpectra)*100);
    isNew = 0;
    for e = 1:numberOfPreviousSpectra
        test = squeeze(exportLibrary(:, i)) - squeeze(previousLibrary(:, e));
        if (sum(test) == 0 && i ~= e)
            isNew = 1;
        end
    end
    if (isNew == 0)
        newSpectra(:, newSpectraIndex) = exportLibrary(:, i);
        newSpectraIndex = newSpectraIndex + 1;
    else
        newSpectraExport(:, newSpectraExportIndex) = exportLibrary(:, i);
        newSpectraExportIndex = newSpectraExportIndex + 1;
    end
end

% Generare figures below
close all;
prettyBar3(scoreArray);

figure;
hold on;
[~, entries] = size(newSpectra);
for i = 1:entries
    plot(spectraToWrite(:, 1), newSpectra(:, i));
    set(gca, 'XDir','reverse');
end

if (sum(newSpectra, 'all') ~= 0)
    prompt = input('Write spectra to library? (y/n): ', 's');
    
    if (prompt == 'y')
        
        prompt = input('Run editor?', 's');
        if (prompt == 'y')
            close all;
            figure;
            backupNewSpectra = newSpectra;
            clear newSpectra;
            newSpectra(:, 1) = zeros(length(xScale), 1);
            newSpectraIndex = 1;
            [~, numberOfSpectra] = size(backupNewSpectra);
            
            i = 1;
            while (i <= numberOfSpectra)
                clc;
                fprintf('Approving new backgrounds: %0.2f%%\n', (i/numberOfSpectra)*100);
                plot(newSpectraExport(:, 1), backupNewSpectra(:, i), 'k');
                set(gca, 'XDir','reverse');
                
                % Calculate the score for each spectrum (to display as a
                % reference)
                spectrumAdj = flip(squeeze(smoothdata(msbackadj(xScale, backupNewSpectra(:, i), 'StepSize', 50), 'gaussian', 7)));
                smallestError = Inf;
                smallestErrorIndex = NaN;
                for index = 1:bgs
                    
                    % Attempt simple point-by-point subtraction-summation
                    
                    error = abs(spectrumAdj - squeeze(smoothdata(normalizedBG(index, :), 'gaussian', 5))');
                    errorSum = sum(error);
                    
                    if (errorSum < smallestError)
                        smallestError = errorSum;
                        smallestErrorIndex = index;
                        spectrumLib = squeeze(smoothdata(normalizedBG(index, :), 'gaussian', 5))';
                    end
                end
                hold on;
                plot(xScale, squeeze(rawBG(1, smallestErrorIndex, :))', 'r');
                hold off;
%                 figure;
%                 hold on;
%                 plot(xScale, spectrumAdj, 'k');
%                 plot(xScale, spectrumLib, 'r');
%                 hold off;
                fprintf('Spectrum score: %s compared to library entry %s\n', num2str(smallestError), num2str(smallestErrorIndex));
                prompt = input('Press return to confirm (or enter "n" or "d" or "r" or "j"): ', 's');
                
                if (isempty(prompt))
                    newSpectra(:, newSpectraIndex) = backupNewSpectra(:, i);
                    newSpectraIndex = newSpectraIndex + 1;
                elseif (prompt == 'd')
                    break;
                elseif (prompt == 'r')
                    i = i - 2;
                    newSpectraIndex = newSpectraIndex - 1;
                    newSpectra = newSpectra(:, 1:newSpectraIndex - 1);
                    if (newSpectraIndex < 1)
                        newSpectraIndex = 1;
                    end
                elseif (prompt == 'j')
                    i = i + 9;
                end
                i = i + 1;
            end
        end
        
        if (sum(newSpectra, 'all') ~= 0)
            exportLibrary = [newSpectraExport newSpectra];
        else
            exportLibrary = newSpectraExport;
        end
        writematrix(exportLibrary, writePath);
        [~, entries] = size(exportLibrary);
        writePath = 'PendingSearches/BGReferencesData.txt';
        writematrix(entries, writePath);
        
        close all;
        fprintf('Exported %d suspected background spectra.\n', entries);
        
        figure;
        hold on;
        [~, entries] = size(exportLibrary);
        for i = 2:entries
            plot(exportLibrary(:, 1), exportLibrary(:, i));
            set(gca, 'XDir','reverse');
        end
    else
        fprintf('Spectra not saved.\n');
    end
else
    fprintf('No new spectra to save.\n');
end