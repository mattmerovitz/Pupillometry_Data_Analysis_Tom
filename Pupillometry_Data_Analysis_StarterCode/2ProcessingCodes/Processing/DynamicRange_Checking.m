%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% PrP preprocessing code, step 1
%
% Summary: Reads in pre-preprocessed (by Alex) data files, one for each
%   subject and for each trial deblinks, smoothes, and bins raw data for
%   each trial [deblinkPrP.m]. Also calculates the max and min pupil size 
%   based on pupil recordings from black and white screens [pupRangePrP.m].
%
% Input: .mat files containing  1. pupil data for each trial, trimmed; 
%                               2. pupil data from black screen;
%                               3. pupil data from white screen.
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

%--- Select and read in list of data files that will be preprocessed ------
[x,filenames] = xlsread('datafiles.xlsx');

%--------------------------------------------------------------------------



%--- Import adjustment timings ---%
timingMods = num2cell(zeros(29,6));


%===== Re-format data & preprocess ========================================

% Cell array to save measurements devs
trialStdDevs = zeros(length(filenames), 29);
trialMeans = zeros(length(filenames), 29);
subjDRMin = zeros(length(filenames), 1);
subjDRMax = zeros(length(filenames), 1);
trialPupStart = zeros(length(filenames), 29);


% Array (matrix) to save number of trials excluded per subject
trialExclusions = zeros(length(filenames), 2);


numBadTrials = 0;

%--- loop thru subjects: load each subj's data & set up output ----------

for sbj=1:length(filenames);
%     sbj=1;   %run one specific subject
    disp('   SUBJ - TRIAL');
    
    load(cell2mat(filenames(sbj)));
    
    tmpID=char(filenames(sbj));
    curSbjID = str2double(tmpID(1:3));
    trialExclusions(sbj,1) = curSbjID;
    
    sbjdataout=zeros(length(trimmedTrials),100); %nrows = ntrials: 29
                                                 %ncols =  nbins: 93 (8-100)
                                                 %       + subj ID (1)
                                                 %       + trial num (2)
                                                 %       + max & min (3-4)
                                                 %       + file info (5-7) 
                                                 
    %--- Determine running order ---
    fName = trimmedTrials{1}{1,1};
    l1 = fName(end-5);
    l2 = fName(end-4);
    if l1 == 'N' && l2 == 'A'
        runOrd = 1;
    elseif l1 == 'N' && l2 == 'B'
        runOrd = 2;
    elseif l1 == 'A' && l2 == 'C'
        runOrd = 3;
    elseif l1 == 'B' && l2 == 'C'
        runOrd = 4;
    elseif l1 == 'A' && l2 == 'I'
        runOrd = 5;
    elseif l1 == 'B' && l2 == 'I'
        runOrd = 6;
    else
        display('Could not determine Running Order')
    end
    
    
    %--- loop thru trials of the current subject --------
    
    for t=1:length(trimmedTrials)
%         t=2;   %run one specific trial of the current subj
        disp([curSbjID t]);
        
        %TEMP set max & min pupil to 0
        sbjdataout(t,3) = 0;
        sbjdataout(t,4) = 0;
        
        
        %record subjID & trialNum
        sbjdataout(t,1) = curSbjID;
        sbjdataout(t,2) = t;
        
        %extract data table for current trial:
        curTrl=trimmedTrials{t};
        
        
        %define current soundfile:
        curFiles = curTrl.soundfile;
        curFile = curFiles(1,:);
        %disp(curFile);
        
        if isletter(curFile(2)), 
            lbl=2; 
        else lbl=3; 
        end

        sbjdataout(t,5) = str2double(curFile(1:lbl-1));   %record sent ID
        
        
        %determine & record sent info:
        stiminfo1 = curFile(lbl);
        if strcmp(stiminfo1,'A'), sbjdataout(t,6)=1; end
        if strcmp(stiminfo1,'B'), sbjdataout(t,6)=2; end
        if strcmp(stiminfo1,'N'), sbjdataout(t,6)=3; end
        
        stiminfo2 = curFile(lbl+1);
        if strcmp(stiminfo2,'A'), sbjdataout(t,7)=1; end
        if strcmp(stiminfo2,'B'), sbjdataout(t,7)=2; end
        if strcmp(stiminfo2,'C'), sbjdataout(t,7)=3; end
        if strcmp(stiminfo2,'I'), sbjdataout(t,7)=4; end
        
        
        %define three time points of interest:
        trialFlagInd = zeros(3,1);
        curMsgs = curTrl.SAMPLE_MESSAGE;
        for m=1:size(curMsgs,1)
            if isletter(curMsgs(m,1))
                if strcmp(curMsgs(m,7),'4'), trialFlagInd(1,1)=m; end   %notes index of 'Begin 4 sec wait...'
                if strcmp(curMsgs(m,7),'p'), trialFlagInd(2,1)=m; end   %notes index of 'Begin playing audio...'
                if strcmp(curMsgs(m,1),'E'), trialFlagInd(3,1)=m; end   %notes index of 'End of Audio File'
            end
        end
        
        trlBegin = trialFlagInd(1);
        sndBegin = trialFlagInd(2);
        sndEnd = trialFlagInd(3);
        %disp([trlBegin sndBegin sndEnd length(curMsgs)-sndEnd])

        if trialFlagInd(1)~=1
            warning('Sample 1 does not appear to be the start of this trial.'); 
            sbjdataout(t,1:100) = NaN;
            continue; 
        end
        if trialFlagInd(2)<4000-50 || trialFlagInd(2)>4000+50, warning('Pre-sentence pause duration may be off for this trial.'); end
        
        %extract pupil data into a matrix
        curPupilCol = curTrl.LEFT_PUPIL_SIZE;
        curPupils = zeros(length(curPupilCol),1);
        for pp=1:length(curPupilCol)
            curPupils(pp) = str2double(curPupilCol(pp,:));
        end
        
        
        
%~~~~~ TRIAL DATA SET UP COMPLETE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              
        %~~~~~ deblink, z-score, smooth, bin ~~~~~
        deblink_Align;
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        

    end   %end  of trial loop

    
    
    
    
%===== Re-format pupil range data & preprocess ============================
    
    blackPupils = blackScreen.LEFT_PUPIL_SIZE;
    blackScr = zeros(length(blackPupils),1);
    for pp=1:length(blackPupils)
        blackScr(pp) = str2double(blackPupils(pp,:));
    end
    
    whitePupils = whiteScreen.LEFT_PUPIL_SIZE;
    whiteScr = zeros(length(whitePupils),1);
    for pp=1:length(whitePupils)
        whiteScr(pp) = str2double(whitePupils(pp,:));
    end
    
    curMin = 0;
    curMax = 0;
    
    %~~~~~ deblink & take mean of plateau ~~~~~
                  pupRangePrP;
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    
    subjDRMin(sbj) = curMin;
    subjDRMax(sbj) = curMax;
    
    
    
%===== Add current subj's data to final output ============================

    newdataout(sbj) = {sbjdataout};
    

end   %end of subject loop



%====== save newdataout ===================================================

% save('PrPdataSummaryRaw.mat', 'newdataout')

%========================================================= End Step 1 =====



%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% PrP preprocessing code, step 2
%
% Summary: Reads in deblinked, smoothed, and binned, but still raw data for
%   each trial of each subject to normalize (to each subject's pupil range)
%   and center (around the pupil value at sentence onset).
%
% Input: cell array [newdataout], read in one sbj at a time [curdata]
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
% Output: cell array [normdataout], one cell for each subject
%           - same data structure as above, except...
%              cols 8-100: binned, normalized, & centered data of each trial
%
% - E. Atagi, 25 March 2016
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

%clear all


%load data (.mat): 
%load('PrPdataSummaryRaw.mat');

numSubj = size(newdataout,2);

%set up output cell array:
% normdataout = {};


for sbj=1:numSubj
    
    curdata = cell2mat(newdataout(sbj));
    numtrials = size(curdata,1);
    
    normdata1 = curdata; %copy all info and raw data (will be overwritten)
%     normdata = curdata;
    
    for t=1:numtrials %normalize and center pupil data for each trial
        
%         %--- normalize to maxRange (col 12) and minRange (col 13) ---------
%         for b=1:56 %loop thru 56 bins per trial
%             maxRange = curdata(t,62);
%             minRange = curdata(t,63);
%             curPupil = curdata(t,b);
%             normdata1(t,b) = ((curPupil-minRange)/(maxRange-minRange))*100;
%         end
%         %------------------------------------------------------------------
        
        
        % BEGINNING-ALIGNED
        atOnset = normdata1(t,28); %get pupil size at bin 21 (first during-sentence bin, col 28)
        trialPupStart(sbj,t) = atOnset;
        % FEATURE-ALIGNED
%         atOnset = normdata1(t,49); %get pupil size at bin 42 (interest area bin, col 49)
        
        %--- center normalized value around value at stimuli onset --------
%         for b=8:100
%             normdata(t,b) = normdata1(t,b)-atOnset;
%         end
        %------------------------------------------------------------------
        
    end
    
%     normdataout(sbj) = {normdata};
    
end


%====== save normdataout ==================================================

% save('PrPdataSummaryNorm.mat', 'normdataout')

%========================================================= End Step 2 =====

