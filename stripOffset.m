function [BCSpectrum] = stripOffset(xScaleLocal, rawSpectrumLocal)

    searchMin = 1400;
    searchMax = 3700;

    BCSpectrum = rawSpectrumLocal - min(rawSpectrumLocal(searchX(xScaleLocal, searchMin):searchX(xScaleLocal, searchMax)));
    
end