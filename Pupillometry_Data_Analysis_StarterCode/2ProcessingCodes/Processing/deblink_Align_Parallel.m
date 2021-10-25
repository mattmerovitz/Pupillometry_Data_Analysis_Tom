%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% PrP preprocessing code: deblink, smooth, and bin raw data
%
% - E. Atagi, 25 March 2016
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function [sbjdataout,trialExclusion] = deblink_Align_Parallel(curPupils, timingMods, sndBegin, runOrd, sbjID, t, minPupil, maxPupil)
    
    %~~~~~ GLOBAL VARIABLES TO EDIT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        %DEBLINK: Set threshold for too much blinking (NORM IN LITERATURE = 15% (0.15))
        %Exclude dataset if more than blinkProp of the data is blinks.
        blinkProp = 0.15;   
        
        %SMOOTHING: Set variable to true for moving window average smoothing. Set variable to false
        %for fancy signal processing.
        moving_window_average = false;
        
        %NORMALIZE: Baseline period (milliseconds) for calibrating original pupil size
        baseline = 2000;
        
        %NORMALIZE: Set variable to true for Z-score normalization. Set variable to false
        %for dynamic range normalization
        zscore = false;
        
        %BINNING: Time in milliseconds per bin
        binSize = 200;
        
    %~~~~~ DO NOT EDIT BELOW ME ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
    sbjdataout = zeros(1,100);
    %~~~~~ 1: Deblink ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %~~~~~ Based on algorithm from Hershman, et. al., 2018 ~~~~~~~~~~~~
    [trialExclusion, curPupils, numBlinks, sbjdataout] = deblink(curPupils, sbjdataout, blinkProp, sndBegin, sbjID, t);

    %~~~~~ 2: Interpolate ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    [curPupils,sbjdataout] = interpolate(numBlinks, curPupils, blinkProp, sbjdataout);

    %~~~~~ 3: Smooth ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    newPupils = smooth(curPupils, moving_window_average);

    %~~~~~ 4: Normalize ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    newPupils = normalize(maxPupil, minPupil, newPupils, timingMods{t, runOrd}, baseline, zscore);

    %~~~~~ 5: Bin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    sbjdataout = binning(newPupils,sbjdataout,binSize);

