%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% PrP preprocessing code: calculate max and min pupil size
%
% - E. Atagi, 25 March 2016
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


function [maxPupil,minPupil] = pupRange(blackScr,whiteScr)


    %+++ maxRange ++++++++++++++++++++
    start = 30000;
    blkPupil = blackScr(start:end,1);   %only use samples from last half of the black screen (30000 samples)
    for samp=1:length(blkPupil)
        if blkPupil(samp) == 0, blkPupil(samp) = NaN; end
    end
            
    blinkVal = nanmean(blkPupil) - (3*nanstd(blkPupil));  %set value by which a blink is defined: 3SD below mean
    for pup=1:length(blkPupil)
        if blkPupil(pup) < blinkVal, blkPupil(pup) = NaN; end %samples during blinks are replaced by NaN 
    end
    
    
    %40 samples before blink are also replaced by NaN to get rid of blink artifacts
    for blnk=1:40
        if isnan(blkPupil(blnk)), blkPupil(1:blnk) = NaN; end
    end
    for blnk=41:length(blkPupil)
        if isnan(blkPupil(blnk)), blkPupil(blnk-40:blnk) = NaN; end
    end
    
    %128 samples after blink are also replaced by NaN to get rid of blink artifacts
    %set up a new array of zeros to fill (fill only when 0), to avoid
    %overwriting NaN's from earlier blink artifact removal process
    newBlack = zeros(length(blkPupil),1);
    for ns=1:length(blkPupil)
        if isnan(blkPupil(ns))
            newBlack(ns:ns+128) = NaN;
        else
            if newBlack(ns)==0, newBlack(ns) = blkPupil(ns); end
        end
    end
    
    maxPupil = nanmean(newBlack);
    
    
    %--- minRange --------------------
    start = 30000;
        
    whtPupil = whiteScr(start:end,1);    %only use samples from last 10 seconds of white screen (10000 samples)
    for samp=1:length(whtPupil)
        if whtPupil(samp) == 0, whtPupil(samp) = NaN; end
    end
            
    blinkVal = nanmean(whtPupil) - (3*nanstd(whtPupil));  %set value by which a blink is defined: 3SD below mean
    for pup=1:length(whtPupil)
        if whtPupil(pup) < blinkVal, whtPupil(pup) = NaN; end %samples during blinks are replaced by NaN 
    end
    
    
    for blnk=1:40
        if isnan(whtPupil(blnk)), whtPupil(1:blnk) = NaN; end
    end
    
    for blnk=41:length(whtPupil)
        if isnan(whtPupil(blnk)), whtPupil(blnk-40:blnk) = NaN; end
    end
    
    
    newWhite = zeros(length(whtPupil),1);
    for ns=1:length(whtPupil)
        if isnan(whtPupil(ns))
            newWhite(ns:ns+128) = NaN;
        else
            if newWhite(ns)==0, newWhite(ns) = whtPupil(ns); end
        end
    end
    
    minPupil = nanmean(newWhite);
    
    end
    
    %+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
    