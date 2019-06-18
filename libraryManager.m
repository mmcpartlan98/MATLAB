clear;
clc;
format compact;
close all;

linearLibrary = csvread('PendingSearches/BGReferences.txt');
prevBackup = csvread('LibraryBackups/BGReferencesIndex.txt');
writematrix(linearLibrary, ['LibraryBackups/BGReferences' num2str(prevBackup) '.txt']);
writematrix(prevBackup + 1, 'LibraryBackups/BGReferencesIndex.txt');

interval = 100;

if (isempty(input('Assume NxN square? (return/n): ', 's')))
    [~, librarySize] = size(linearLibrary);
    rowLength = sqrt(librarySize - 1);
    colLength = rowLength;
end

libraryOut = linearLibrary(:, 1);
[~, libraryMaxIndex] = size(linearLibrary);
i = 2;
while i < libraryMaxIndex
    
    close all;
    plotFigure = figure;
    hold on;
    
    if (i + interval <= libraryMaxIndex)
        maxIndex = i + interval;
    else
        [~, maxIndex] = size(linearLibrary);
    end
    
    for plotIndex = i:maxIndex
        plot(linearLibrary(:, 1), linearLibrary(:, plotIndex));
    end
    
    prompt = input(sprintf('Keep spectra %d to %d? (return/no): ', i - 1, maxIndex - 1), 's');
    
    if isempty(prompt)
        libraryOut = [libraryOut linearLibrary(:, i:(maxIndex - 1))];
    else
        tempOutputCollection = [];
        for plotIndex = i:maxIndex
            close all;
            plotFigure = figure;
            plot(linearLibrary(:, 1), linearLibrary(:, plotIndex));
            
            prompt = input(sprintf('Keep spectrum %d of %d? (return/n): ', plotIndex - i + 1, maxIndex - i + 1), 's');
            
            if (isempty(prompt))
                tempOutputCollection = [tempOutputCollection linearLibrary(:, plotIndex)];
            end
            
        end
        libraryOut = [libraryOut tempOutputCollection];
    end
    
    i = maxIndex;
end

prompt = input('Write new library? (y/n): ', 's');
if (prompt == 'y')
    writematrix(libraryOut, 'PendingSearches/BGReferences.txt');
end