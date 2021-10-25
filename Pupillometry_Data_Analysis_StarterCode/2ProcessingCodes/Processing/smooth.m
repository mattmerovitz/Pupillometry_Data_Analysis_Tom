function newPupils = smooth(curPupils, moving_window_average)
    if (moving_window_average)
       
        disp("Not yet implemented. Please change the moving_window_average variable and try again.")
    
    else 
        
        %Filter Variables for Smoothing
        filtOrder = 50;
        lowBandHz = 0.025;
        highBandHz = 25;

        % For bandpass filter, add 50 samples to beginning and end of data
        startAddition = ones(filtOrder,1);
        startAddition = startAddition * curPupils(1);
        endAddition = ones(filtOrder,1);
        endAddition = endAddition * curPupils(end);

        additionPupils = vertcat(startAddition, curPupils);
        additionPupils = vertcat(additionPupils, endAddition);

        % Bandpass FIR filter (.025Hz to 25Hz), window method, as in (Zenon, 2014)
        lowBound = lowBandHz * ((2*pi) / 1000);
        highBound = highBandHz * ((2*pi) / 1000);
        filt = fir1(filtOrder, [lowBound highBound], 'bandpass', hamming(filtOrder+1));
        hd = dfilt.dffir(filt);
        newPupils = filter(hd, additionPupils);

        % Trim away data additions of length "filtOrder"
        newPupils = newPupils(filtOrder:end-filtOrder);
    end