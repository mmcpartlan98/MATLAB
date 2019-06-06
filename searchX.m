function [retCol, retRow] = searchX(x, y)
% Search X for Y. Returns [row, column] of either closest match or first encountered exact
% match. X can be a vector or array, Y must be a value.
x = x';
[rows, columns] = size(x);
maxVal = Inf;
for iRow = 1:rows
    for iCol = 1:columns
        if (x(iCol) - y == 0)
            retRow = iRow;
            retCol = iCol;
            return;
        end
        if (abs(x(iCol) - y) < maxVal)
            maxVal = abs(x(iCol) - y);
            retRow = iRow;
            retCol = iCol;
        end
    end
end
end