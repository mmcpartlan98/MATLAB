function [retRow, retCol] = searchX(x, y)
% Search X for Y. Returns [row, column] of either closest match or first encountered exact
% match. X can be a vector or array, Y must be a value.
[rows, columns] = size(x);
maxVal = Inf;
for iRow = 1:rows
    for iCol = 1:columns
        x(iCol) = x(iCol) - y;
        if (x(iCol) == 0)
            retRow = iRow;
            retCol = iCol;
            return;
        end
        if (x(iCol) < maxVal)
            maxVal = x(iCol);
            retRow = iRow;
            retCol = iCol;
        end
    end
end
end