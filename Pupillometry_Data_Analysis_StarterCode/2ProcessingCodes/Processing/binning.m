function sbjdataout = binning(newPupils,sbjdataout, binSize)

    numBins = length(newPupils)/binSize;    
    numBins = int64(ceil(numBins));      % make sure numBins is an integer, 
                                        % rounded up from actual number  
                                        
    if numBins+1 > 92
        disp("WARNING: Number of available bins is smaller than calculated number of bins according to bin size.")
    end 
    
    for bin=1:numBins
        % average 200ms, without NaNs and without zeros
        start = 1 + ((bin-1)*binSize);
        if start+binSize-1 > length(newPupils)
            m = nanmean(nonzeros(newPupils(start:end)));
        else
            m = nanmean(nonzeros(newPupils(start:start+binSize-1)));
        end
        sbjdataout(1,bin+8) = m;
    end
    if numBins+1 <= 92
        for fill=numBins+1:92
            sbjdataout(1,fill+8) = NaN;   % DECIDE WHETHER EMPTY SHOULD BE ZERO OR NaN-ed
        end
    end
