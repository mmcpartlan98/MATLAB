function [figureName] = prettyBar3(grid)
figureName = figure;
c = bar3(grid);

for k = 1:length(c)
    zdata = c(k).ZData;
    c(k).CData = zdata;
    if (c(k) == 0)
        c(k).FaceColor = 'none';
    else
        c(k).FaceColor = 'interp';
    end
end

for i = 1:numel(c)
    %# get the ZData matrix of the current group
    Z = get(c(i), 'ZData');
    
    %# row-indices of Z matrix. Columns correspond to each rectangular bar
    rowsInd = reshape(1:size(Z,1), 6,[]);
    
    %# find bars with zero height
    barsIdx = all([Z(2:6:end, 2:3) Z(3:6:end, 2:3)] == 0, 2);
    
    %# replace their values with NaN for those bars
    Z(rowsInd(:, barsIdx),:) = NaN;
    
    %# update the ZData
    set(c(i), 'ZData', Z);
end
end