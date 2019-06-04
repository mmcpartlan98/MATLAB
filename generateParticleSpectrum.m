function bestSpectra = generateParticleSpectrum(clustersLocal, particleIndex, rawSpectraLocal, xScaleLocal)
[rowsLocal, colsLocal] = size(clustersLocal);
sumSpectrum = zeros(length(xScaleLocal), 1);
count = 0;
for rowLocal = 1:rowsLocal
    for colLocal = 1:colsLocal
        if (clustersLocal(rowLocal, colLocal) == particleIndex)
            sumSpectrum = sumSpectrum + squeeze(rawSpectraLocal(rowLocal, colLocal, :));
            count = count + 1;
        end
    end
end
bestSpectra = sumSpectrum ./ count;
end