% Returns the non-normalized SINC function
% sin(x)/x for all real numbers except 0

function sincOut = newSinc(x)

sincOut = zeros(1, length(x));
for i = 1:length(x)
    if (x(i) ~= 0)
        sincOut(i) = sin(x(i))./x(i);
    else
        sincOut(i) = 1;
    end
end
end