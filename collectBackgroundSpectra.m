clear;
clc;
format compact;

% Use this script to generate a file of background spectra
cutoff = 160;
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

backgroundPath = csvread('/Users/mattmcpartlan/Desktop/PendingSearches/BGReferences.txt');
[~, bgs] = size(backgroundPath);
bgs = bgs - 1;

[xScale, correctedSpectra, rawSpectra, ~] = dptRead(readPath, rowLength, colLength, 'n', 'Parsing map spectrum');



scoreArray = zeros(rowLength, colLength);
% Assume only one background to be loaded for now
[~, correctedBG, rawBG, ~] = dptRead(backgroundPath, 1, bgs, 'n', 'Parsing library data');
correctedBG = squeeze(smoothdata(correctedBG, 'gaussian', 5));

for i = 1:rowLength
    for e = 1:colLength
        spectrum = squeeze(smoothdata(correctedSpectra(i, e, :), 'gaussian', 7));
        clc;
        fprintf('Stripping background: %0.2f%% complete\n', (((i - 1) * colLength + e)/(rowLength * colLength)) * 100);
        for index = 1:bgs
            
            % Attempt simple point-by-point subtraction-summation
            
            error = abs(spectrum - correctedBG(index, :)');
            errorSum = sum(error);
            smallestError = Inf;
            
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
writePath = '/Users/mattmcpartlan/Desktop/PendingSearches/BGReferences.txt';
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
b = bar3(scoreArray);

for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    if (b(k) == 0)
        b(k).FaceColor = 'none';
    else
        b(k).FaceColor = 'interp';
    end
end

for i = 1:numel(b)
    %# get the ZData matrix of the current group
    Z = get(b(i), 'ZData');
    
    %# row-indices of Z matrix. Columns correspond to each rectangular bar
    rowsInd = reshape(1:size(Z,1), 6,[]);
    
    %# find bars with zero height
    barsIdx = all([Z(2:6:end, 2:3) Z(3:6:end, 2:3)] == 0, 2);
    
    %# replace their values with NaN for those bars
    Z(rowsInd(:, barsIdx),:) = NaN;
    
    %# update the ZData
    set(b(i), 'ZData', Z);
end

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
                plot(newSpectraExport(:, 1), backupNewSpectra(:, i));
                set(gca, 'XDir','reverse');
                prompt = input('Press return to confirm (or enter "n" or "d" or "r"): ', 's');
                if (isempty(prompt))
                    newSpectra(:, newSpectraIndex) = backupNewSpectra(:, i);
                    newSpectraIndex = newSpectraIndex + 1;
                elseif (prompt == 'd')
                    break;
                elseif (prompt == 'r')
                    i = i - 2;
                    newSpectraIndex = newSpectraIndex - 1;
                    newSpectra = newSpectra(:, 1:newSpectraIndex - 1);
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
        writePath = '/Users/mattmcpartlan/Desktop/PendingSearches/BGReferencesData.txt';
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