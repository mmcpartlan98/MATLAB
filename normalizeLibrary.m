clc;
clear;
format compact;

linearLibrary = csvread('PendingSearches/BGReferences.txt');
[~, arLength] = size(linearLibrary);

figure;

for i = 2:arLength
    fprintf('Normalizing library %0.2f%%\n', i/(arLength)*100);
    tempArea = trapz(squeeze(linearLibrary(:, 1)), squeeze(linearLibrary(:, i)));
    linearLibrary(:, i) = linearLibrary(:, i) / tempArea;
    hold on;
    plot(squeeze(linearLibrary(:, 1)), squeeze(linearLibrary(:, i)));
end
