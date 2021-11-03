function [trialExclusion, curPupils, numBlinks, sbjdataout] = deblink(curPupils, sbjdataout, blinkProp, sndBegin, sbjID, t)
    trialExclusion = 0;
    
    for s=1:length(curPupils)
        if curPupils(s) == 0, curPupils(s) = NaN; end
    end

    %%% Deblink (based on algorithm from Hershman, et. al., 2018) %%%

    % smoothed version of data to do algorithm on
    smoothPupils = curPupils;
    for i = 6:length(smoothPupils)-6
        smoothPupils(i) = mean(curPupils(i-5:i+5));
    end
    
    % search through original to find NaN sections
    blinkStart = 0;
    blinkEnd = 0;
    blinkExtra = 0;
    for i = 1:length(curPupils)
        % if there is a NaN and we aren't already in blink, previous sample
        % is last before blink (also make sure we aren't catching up to
        % portion removed by blink removal)
        if (isnan(curPupils(i)) && ~blinkStart && i>blinkExtra)
            if i == 1
                blinkStart = 1;
            else
                blinkStart = i-1;
            end
        end
        % if this is actual number, and we were in blink, i is end of blink
        if (~isnan(curPupils(i)) && blinkStart)
            blinkEnd = i;
        end

        % if we have blink start and blink end, handle blink detection
        if blinkStart && blinkEnd
            % find end of blink in smooth pupils
            if ~(blinkEnd == length(curPupils))
                while (~(blinkEnd==length(smoothPupils)) && ~isnan(smoothPupils(blinkEnd+1)) && (smoothPupils(blinkEnd+1) > smoothPupils(blinkEnd)))
                    blinkEnd = blinkEnd + 1;
                end
            end

    %         if blinkEnd == length(curPupils)
    %             % find start of blink in smooth pupils
    %             while (~(blinkStart==1) && ~isnan(smoothPupils(blinkStart-1)) && (smoothPupils(blinkStart-1) > smoothPupils(blinkStart)))
    %                 blinkStart = blinkStart - 1;
    %             end;
    %             % delete all data in blink, reset blink boundaries
    %             smoothPupils(blinkStart:blinkEnd) = NaN;
    %             curPupils(blinkStart:blinkEnd) = NaN;
    %             blinkExtra = blinkEnd;
    %             blinkEnd = 0;
    %             blinkStart = 0;
            if isnan(smoothPupils(blinkEnd+1))      % make sure it's not double blink
                smoothPupils(blinkStart:blinkEnd) = NaN;
                curPupils (blinkStart:blinkEnd) = NaN;
                blinkEnd = 0;
            else
                % find start of blink in smooth pupils
                while (~(blinkStart==1) && ~isnan(smoothPupils(blinkStart-1)) && (smoothPupils(blinkStart-1) > smoothPupils(blinkStart)))
                    blinkStart = blinkStart - 1;
                end
                % delete all data in blink, reset blink boundaries
                smoothPupils(blinkStart:blinkEnd) = NaN;
                curPupils(blinkStart:blinkEnd) = NaN;
                blinkExtra = blinkEnd;
                blinkEnd = 0;
                blinkStart = 0;
            end
        end
    end



    numBlinks = sum(isnan(curPupils));


    % Check that there is enough data in pre-sentence wait
    sec2NumNaN = sum(isnan(curPupils(1:sndBegin-1)));
    sec2PropNaN = (sec2NumNaN / 2000);
    NaNProp = .25;

    %#########  Print out proportion of data in trial that is blinking  ###########
    %disp([num2str(sbjID), 'trial number ', num2str(t), ' has proportion of blinking... ', num2str(numBlinks/length(curPupils))]);
    disp(numBlinks/length(curPupils));
    if numBlinks/length(curPupils) > blinkProp  %if more than 15% of samples are blinks,
        curPupils(:)=NaN;                       %replace all pupil data with NaN to exclude trial from analysis
        sbjdataout(1,9:100)=NaN;
        disp(['Trial Excluded - Too many blinks: sbj ', num2str(sbjID), ' trial ', num2str(t)]);
        trialExclusion = 1;
    elseif sec2PropNaN >= NaNProp
        curPupils(:) = NaN;
        sbjdataout(1,9:100)=NaN;
        disp(['Trial Excluded - Not enough pre-sentence data: sbj ', num2str(sbjID), ' trial ', num2str(t)]);
        trialExclusion = 1;
    end