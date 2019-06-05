function [clusters] = clusterSpectra(inflectionsFullLocal, plotResultsLocal, scoreArrayLocal)

[rows, cols, ~] = size(inflectionsFullLocal);
clusters = zeros(rows, cols);

% Adjacent squares must be within 10% scores to count as a cluster
hitThreshold = 0.25;

backgroundCutoff = mean(scoreArrayLocal, 'all') + 3 * std(scoreArrayLocal);

% Calculate background
for row = 1:rows
    for col = 1:cols
        fprintf('Calculating background on cell %d, %d\n', row, col);
        if (scoreArrayLocal(row, col) < backgroundCutoff)
            scoreArrayLocal(row, col) = 0;
        end
    end
end

for row = 1:rows
    for col = 1:cols
        fprintf('Clustering on cell %d, %d\n', row, col);
        if (scoreArrayLocal(row, col) ~= 0)
            minCutoff = scoreArrayLocal(row, col) - scoreArrayLocal(row, col) * hitThreshold;
            maxCutoff = scoreArrayLocal(row, col) + scoreArrayLocal(row, col) * hitThreshold;
            scoreArrayTemp = scoreArrayLocal;
            for internalRow = 1:rows
                for internalCol = 1:cols
                    scoreArrayTemp(internalRow, internalCol) = scoreArrayLocal(internalRow, internalCol) * (scoreArrayLocal(internalRow, internalCol) > minCutoff && scoreArrayLocal(internalRow, internalCol) < maxCutoff);
                    if (scoreArrayTemp(internalRow, internalCol) ~= 0)
                        scoreArrayTemp(internalRow, internalCol) = 1;
                    end
                end
            end
            % Image processing of binary Image
            newCluster = bwlabel(scoreArrayTemp);
            [clusterRows, clusterCols] = size(newCluster);
            for clusterIndex = 1:(clusterRows * clusterCols)
                if (newCluster(clusterIndex) ~= 0)
                    newCluster(clusterIndex) = 1;
                end
            end
            clusters = clusters + newCluster;
        end
    end
end


% Strip hit counts and number particles
for row = 1:rows
    for col = 1:cols
        fprintf('Numbering particles %d, %d\n', row, col);
        if (clusters(row, col) ~= 0)
            clusters(row, col) = 1;
        end
    end
end
clusters = bwlabel(clusters);

% Plot if running as a stand-alone
if (plotResultsLocal == 'y')  
    b = bar3(clusters);
    
    for k = 1:length(b)
        zdata = b(k).ZData;
        b(k).CData = zdata;
        b(k).FaceColor = 'interp';
    end
end
end