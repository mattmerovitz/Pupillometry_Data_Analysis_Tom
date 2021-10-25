%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% PrP preprocessing code: deblink, smooth, and bin raw data
%
% - E. Atagi, 25 March 2016
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


%deblinkPrP


%~~~~~ 1: deblink ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for s=1:length(curPupils)
    if curPupils(s) == 0, curPupils(s) = NaN; end
end

blinkVal = nanmean(curPupils) - (3*nanstd(curPupils));  %set value by which a blink is defined: 3SD below mean
for p=1:length(curPupils)
    if curPupils(p) < blinkVal, curPupils(p) = NaN; end %samples during blinks are replaced by NaN 
end

numBlinks = sum(isnan(curPupils));
blinkProp = 0.85;   %SET THRESHOLD FOR TOO MUCH BLINKING: NORM IN LITERATURE = 15% (0.15)

if numBlinks > blinkProp*length(curPupils)  %if more than 15% of samples are blinks,
    curPupils(:)=NaN;                       %replace all pupil data with NaN to exclude trial from analysis
    sbjdataout(t,1:15)=NaN;
end

if numBlinks <= blinkProp*length(curPupils)
    % linear interpolation to fill in NaNs 
    % based on A samples before and B samples after blink
    A = 40;
    B = 128;

    for ss=1:length(curPupils)

       %--- look for beginning of a blink ---------------
        if isnan(curPupils(ss))
            x1=ss-A; 
            if ss<=A, x1 = 1; end


            for si=ss:length(curPupils)-B

               %--- check for end of blink ----------
                if curPupils(si) > 0 && curPupils(si+B) > 0

                    if si+B > length(curPupils)
                        x2 = length(curPupils); 
                    else

                        x2 = si+B;  
                    end

                    break;
                end
               %-------------------------------------
            end

            y1 = curPupils(x1);                    
            y2 = curPupils(x2);

            if isnan(y1), y1=y2; end
            if isnan(y2), y2=y1; end

            %linear interpolation:
            for x=x1:x2
                curPupils(x) = y1 + ( ( (y2-y1)/(x2-x1) )*(x-x1) );
            end
        end
       %-------------------------------------------------
    end


    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end deblinking ~~~~~~~~~~



    %~~~~~~ Z-Score ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     % Z-Score relative to whole trial
%     meanPup = nanmean(curPupils);
%     stdDev = nanstd(curPupils);
    % Z-Score relative to 4sec wait at beginning
    meanPup = nanmean(curPupils(1:sndBegin-1));
    stdDev = nanstd(curPupils(1:sndBegin-1));
%     % Record Means and Std Devs
%     trialMeans(sbj,t) = meanPup;
%     trialStdDevs(sbj,t) = stdDev;
    for p=1:length(curPupils)
        cur = curPupils(p);
        score = (cur - meanPup) / stdDev;
        curPupils(p) = score;
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    %~~~~~ 2: smooth ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    newPupils = zeros(length(curPupils),1);

    %moving average of 101 samples (101 ms):
    mavg = 50;
    for d=1:length(curPupils)
        if d+mavg>length(curPupils)
            newPupils(d) = NaN;
        else
            if d<=mavg, newPupils(d) = mean(curPupils(1:d+mavg)); end
            if d>mavg && d<length(curPupils)-mavg, newPupils(d) = mean(curPupils(d-mavg:d+mavg)); end
            if d>=length(curPupils)-mavg, newPupils(d) = mean(curPupils(d:length(curPupils))); end
        end
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end smoothing ~~~~~~~



    %~~~~~ 3: bin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    %fill in sbjdataout cols 1-56 (1-20:pre, 21-40:dur, 41-56:post)
    for binPre=1:20
        sx = trlBegin + (binPre-1)*200;    %index of first sample for this bin (200ms bins)
        sbjdataout(t,binPre) = mean(newPupils(sx:sx+199));
    end

    for binDur=1:20
        binSize = (sndEnd-sndBegin)/20;    %calculate bin duration for current sentence
        sy = ceil(sndBegin + (binDur-1)*binSize);   %index of first sample for this bin
        syEnd = ceil(sy + binSize);                 %index of last sample for this bin
        sbjdataout(t,binDur+20) = mean(newPupils(sy:syEnd)); %mean of samples for this bin
    end

    for binPost=1:16
        sz = sndEnd + 1 + (binPost-1)*230; %index of first sample for this bin (230ms bins)
        sbjdataout(t,binPost+40) = nanmean(newPupils(sz:sz+190));
    end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end binning ~~~~~~~~~

end


