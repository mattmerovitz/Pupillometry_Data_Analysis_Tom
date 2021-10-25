%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% NAPT preprocessing code, step 1
%
% Summary: Reads in pre-preprocessed (by Alex) data files, one for each
%   subject and for each trial deblinks, smoothes, and bins raw data for
%   each trial [deblinkPrP.m]. Also calculates the max and min pupil size 
%   based on pupil recordings from black and white screens [pupRangePrP.m].
%
% Input: .mat files containing  1. pupil data from black screen;
%                               3. pupil dal data for each trial, trimmed; 
%                               2. pupita from white screen.
%
% Output: cell array [newdataout], one cell for each subject
%           - cols 1-56: deblinked, smoothed, binned raw data of each trial
%           - cols 57-59: soundfile information (sentNum, letter1, letter2)
%           - col 60: trialNum
%           - col 61: sbjID
%           - col 62, 63: max pupil, min pupil
%           NEW
%           - col 1: sbjID
%           - col 2 trialNum
%           - cols 3, 4: max pupil, min pupil
%           - cols 5-7: soundfile information (sentNum, letter1, letter2)
%           - cols 8-100: deblinked, smoothed, time-locked, binned raw data of each trial
%
% - E. Atagi, 25 March 2016
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

clear all

tic     % Time execution of script
pool = gcp;

% ticBytes(pool);  % Keep track of amoutn of data being sent to parpool workers

%--- Select and read in list of data files that will be preprocessed ------
[x,filenames] = xlsread('datafiles.xlsx');

%--------------------------------------------------------------------------

newdataout = cell(1,1);

pupilCheck = cell(1,1);

%--- Import adjustment timings ---%
mods = xlsread('EndAlignBuffer.xlsx', 'A1:H96');
timingMods = num2cell(mods);

% timingMods = num2cell(zeros(96,8));


%===== Re-format data & preprocess ========================================

% Array (matrix) to save number of trials excluded per subject
trialExclusions = num2cell(zeros(length(filenames), 1));

% Load in condition data
conditions = xlsread('conditions.xlsx', 'C3:J98');


% numBadTrials = 0;

%--- loop thru subjects: load each subj's data & set up output ----------

parfor sbj=1:length(filenames)
%     sbj=1;   %run one specific subject
    disp('   SUBJ - TRIAL');
    
    cd('../../1Data/4ExtractedData');
    d = load(cell2mat(filenames(sbj)));
    cd('../../2ProcessingCodes/Processing');
    trimmedTrials = d.trimmedTrials;
    whiteScreen1 = d.whiteScreen1;
    blackScreen1 = d.blackScreen1;
    whiteScreen2 = d.whiteScreen2;
    blackScreen2 = d.blackScreen2;
    
    tmpID=char(filenames(sbj));
    curSbjID = str2double(tmpID(1:4));
    
    sbjdataout=zeros(length(trimmedTrials),100); %nrows = ntrials: 96
                                                 %ncols =  nbins: 93 (8-100)
                                                 %       + subj ID (1)
                                                 %       + trial num (2)
                                                 %       + max & min (3-4)
                                                 %       + file info (5-7) 
                                                 
                                                 %       + subjID (1)
                                                 %       + runOrd (2)
                                                 %       + Trial Num (3)
                                                 %       + Condition (4)
                                                 %       + max1 & min1 (5-6)
                                                 %       + max2 & min2 (7-8)
                                                 %       + nbins: 92 (9-100)

                                                 
    %--- Determine running order & Select condition data for running order ---
    runOrd = str2double(tmpID(4));
    for i = 1:length(trimmedTrials)
        newdataout{sbj}(i,2) = runOrd;
        newdataout{sbj}(i,4) = conditions(i,runOrd)
    end

    
    
    %===== Re-format pupil range data & preprocess ============================
    
    % figure out which data column to use (column 1 is Left_Pupil, column 2
    % is Right_Pupil
    blackScrnSize = size(blackScreen1);
    blackScr = zeros(blackScrnSize(1),2);
    for i=1:length(blackScr)
        blackScr(i,1) = str2double(table2array(blackScreen1(i,1)));
        blackScr(i,2) = str2double(table2array(blackScreen1(i,2)));
    end
    
    dataCol = 0;
    blackScrMeans = nanmean(blackScr);
    if ~isnan(blackScrMeans(1))
        dataCol = 1;
    elseif ~isnan(blackScrMeans(2))
        dataCol = 2;
    else
        display(horzcat('Data column not found in subj: ', curSbjID));
    end
        
%     for i = 1:size(blackScreen1,1)
%         left = blackScreen1(i,1);
%         right = blackScreen1(i,2);
%         if isnum(left)
%             dataCol = 1;
%             break;
%         elseif isnum(right)
%             dataCol = 2;
%             break;
%         end
%     end
    
    
    % Convert black and white screen data from strings to doubles
    [max1,min1] = getScreenMaxMin(blackScreen1(:,dataCol), whiteScreen1(:,dataCol));
    [max2,min2] = getScreenMaxMin(blackScreen2(:,dataCol), whiteScreen2(:,dataCol));
    
    % Add daynamic ranges to data sheet
    for i = 1:length(trimmedTrials)
        newdataout{sbj}(i,5) = max1;
        newdataout{sbj}(i,6) = min1;
        newdataout{sbj}(i,7) = max2;
        newdataout{sbj}(i,8) = min2;
    end
    
    % Choose which black and white screen data to normalize to (screen 1 by default)
    if (isnan(max1)) || (isnan(min1))
        if (isnan(max2)) || (isnan(min2))
            % remove subject's data
        end
        minPupil = min2;
        maxPupil = max2;
    else
        minPupil = min1;
        maxPupil = max1;
    end
    
%     blackScrnCol = blackScreen(:,2);
%     blackScrnPupil = size(blackScrnCol);
%     blackScr = zeros(blackScrnPupil(1),1);
%     for pp=1:length(blackScr)
%         blackScr(pp) = str2double(table2array(blackScrnCol(pp,:)));
%     end
%     
%     whiteScrnCol = whiteScreen(:,2);
%     whiteScrnPupil = size(whiteScrnCol);
%     whiteScr = zeros(whiteScrnPupil(1),1);
%     for pp=1:length(whiteScr)
%         whiteScr(pp) = str2double(table2array(whiteScrnCol(pp,:)));
%     end
%     
%     %~~~~~ deblink & take mean of plateau ~~~~~
%     [maxPupil,minPupil] = pupRange(blackScr,whiteScr);
%     for i = 1:96
%         newdataout{sbj}(i,3) = maxPupil;
%         newdataout{sbj}(i,4) = minPupil;
%     end;
%     %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    
    
    
    %--- loop thru trials of the current subject --------
    
    for t=1:length(trimmedTrials)
%       t=2;   %run one specific trial of the current subj
        disp([curSbjID t]);
        
        %record subjID & trialNum
        newdataout{sbj}(t,1) = curSbjID;
        newdataout{sbj}(t,3) = t;
        
        %extract data table for current trial:
        curTrl=trimmedTrials{t};
        
                
        
        %define three time points of interest:
        trialFlagInd = zeros(3,1);
        curMsgs = curTrl.SAMPLE_MESSAGE;
        for m=1:size(curMsgs,1)
            if isletter(curMsgs(m,1))
                
                if strcmp(curMsgs(m,1),'B'), trialFlagInd(1,1)=m; end   %notes index of 'Blank screen baseline'
                if strcmp(curMsgs(m,12),'s'), trialFlagInd(2,1)=m; end   %notes index of 'Sound file start'
                if strcmp(curMsgs(m,12),'e'), trialFlagInd(3,1)=m; end   %notes index of 'Sound file end'
            end
        end
        
        % name trial index flag variables
        trlBegin = trialFlagInd(1);
        sndBegin = trialFlagInd(2);
        sndEnd = trialFlagInd(3);

        if trialFlagInd(1)~=1
            warning('Sample 1 does not appear to be the start of trial %d for subject %d.', t, curSbjID); 
            newdataout{sbj}(t,1:100) = NaN;
            continue; 
        end
        if trialFlagInd(2)<2000-50 || trialFlagInd(2)>2000+50, warning('Pre-sentence baseline may be off for this trial.'); end
        if trialFlagInd(3)<(size(curMsgs,1)-2000)-50 || trialFlagInd(3)>(size(curMsgs,1)-2000)+50, warning('Post-sentence baseline may be off for this trial.'); end

        
        %extract pupil data into a matrix
        curPupilCol = curTrl(:,dataCol);
        curPupilSize = size(curPupilCol);
        curPupils = zeros(curPupilSize(1),1);
        for pp=1:length(curPupils)
            curPupils(pp) = str2double(table2array(curPupilCol(pp,:)));
        end
        
        
%~~~~~ TRIAL DATA SET UP COMPLETE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        %~~~~~ deblink, z-score, smooth, bin ~~~~~
        [trldataout,trlexclude] = deblink_Align_Parallel(curPupils, timingMods, sndBegin, runOrd, curSbjID, t, minPupil, maxPupil);
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        newdataout{sbj}(t,9:100) = trldataout(9:100);
        trialExclusions{sbj} = trialExclusions{sbj} + trlexclude;
        

    end   %end  of trial loop
    
end   %end of subject loop



%====== save newdataout ===================================================

save('dataSummaryNorm.mat', 'newdataout')

%========================================================= End Step 1 =====

% tocBytes(pool)  % Display amount of data sent between parpool workers
toc     % Display time to execute script
