%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% NAPT preprocessing code, step 2
%
% Summary: Reads in binned, z-scored, trial-by-trial data for each 
%   subject and finds mean values for each trial condition.
%
% Input: cell array [newdataout], read in one sbj at a time [curdata]
%           - cols 1-56: binned, normalized, & centered data for each trial
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
% Output: matrix [procData], 3 rows per subject (Incong, Cong, Neut)
%           - cols 1-3: sbjID, max pupil, min pupil
%           - col 4: condition (1=Incong, 2=Cong, 3=Neutral
%           - col 5-60: bins of mean pupil data
%           - col 61, 62: peak pupil amplitude, peak latency for condition
%           NEW
%           - cols 1-3: sbjID, max pupil, min pupil
%           - col 4: condition (1=Incong, 2=Cong, 3=Neutral
%           - col 5, 6: peak pupil amplitude, peak latency for condition
%           - col 7-99: bins of mean pupil data
%           - col 100: peak in window is not global peak (1=yes, 0=no)
%           - col 101-102: pupil change slope - during sentence, post-sentence
%
% - E. Atagi, 29 March 2016
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

clear all


%load data (.mat): 
load('dataSummaryNorm.mat');

numSubj = size(newdataout,2);


%set up output matrix
procData = zeros(numSubj*27,101); %sbjID, max&min 1&2, cond, peak amp & latency, 92 bins, peak change, slopes


% Decide whether to get subset of data
allOrNot = input('Do you want to analyze all data? "y" for yes, "n" to analyze a subset of the data.\n->', 's');

if allOrNot == 'n'
    whichSubset = input('What subset of the data?\n    - "Correct" for 100% correct trials\n    - "Grammatical" for all grammatical response trials\n->', 's');
    if strcmp(whichSubset, 'Correct')
        sheet = '100correct';
        disp('You are analyzing 100% correct trials');
    elseif strcmp(whichSubset, 'Grammatical')
        sheet = 'grammaticalerrors';
        disp('You are analyzing all grammatical trials');
    end
    % Read in subject scores for excluding trials
    excelSheetRange = 'A1:Q37';
    allInclude = xlsread('Pupillometry_Trial_Filters.xlsx', sheet, excelSheetRange, 'basic');
    neg = input('Negate inlcuded columns? "y" for yes, "n" for no.\n->', 's');
end


dataCheck1{numSubj} = [];
currow = 0; %start counter
for sbj=1:numSubj
    
    curdata = newdataout{sbj};
    
    subjID = curdata(1,1);
    
    if allOrNot == 'n'
        % Figure out correct subject column
        curCol = 0;
        s = size(allInclude);
        display(s);
        for col=1:s(2)
            if allInclude(1,col) == subjID
                curCol = col;
                display(subjID);
            end
        end
        % Get rid of bad trials here
        display(curCol);
        includeRows = allInclude(2:end, curCol);
        switch neg
            case 'y'
                includeRows = ~includeRows;
            case 'n'
                includeRows = includeRows;
            otherwise
                'Invalid Input for neg.\n'
        end
        % NaN for trials you don't want
        curdata(~includeRows, 9:100) = NaN;
    end
    
    
    dataCheck1{sbj} = curdata;

    
    for r=1:27  % 
        
        currow = currow+1;  %move down one row
        
        %--- insert subj info ---------------------------------------------
        procData(currow,1:5) = curdata(1,[1 5 6 7 8]);  %sbjID, maxRange, minRange
        %------------------------------------------------------------------
        
        
        %--- define condition ---------------------------------------------
        procData(currow,6)=r;
        %------------------------------------------------------------------
        
        
        %--- subset data for current condition only -----------------------
        
        % Condition numbering key:
        %       SP = Self-Paced, H = High Probabiity, V = Vocoded, C =
        %       Continuous, L = Low Probability, U = Unprocessed
        %       1 = SP, H, V
        %       2 = SP, H, U
        %       3 = SP, L, V
        %       4 = SP, L, U
        %       5 = C , H, V
        %       6 = C , H, U
        %       7 = C , L, V
        %       8 = C , L, U
        % Conditions averaged by pacing, cloze-prob, and vocoding
        if r==1, condind = find(curdata(:,4)==1); end
        if r==2, condind = find(curdata(:,4)==2); end
        if r==3, condind = find(curdata(:,4)==3); end
        if r==4, condind = find(curdata(:,4)==4); end
        if r==5, condind = find(curdata(:,4)==5); end
        if r==6, condind = find(curdata(:,4)==6); end
        if r==7, condind = find(curdata(:,4)==7); end
        if r==8, condind = find(curdata(:,4)==8); end
        
        % Condition numbering key (cont.):
        %       9 =  H, V
        %       10 = H, U
        %       11 = L, V
        %       12 = L, U
        % Collapse across pacing
        if r==9, condind = find(curdata(:,4)==1 | curdata(:,4)==5); end
        if r==10, condind = find(curdata(:,4)==2 | curdata(:,4)==6); end
        if r==11, condind = find(curdata(:,4)==3 | curdata(:,4)==7); end
        if r==12, condind = find(curdata(:,4)==4 | curdata(:,4)==8); end
        
        % Condition numbering key (cont.):
        %       13 = SP, V
        %       14 = C , U
        %       15 = SP, V
        %       16 = C , U
        % Collapse across cloze-prob
        if r==13, condind = find(curdata(:,4)==1 | curdata(:,4)==3); end
        if r==14, condind = find(curdata(:,4)==2 | curdata(:,4)==4); end
        if r==15, condind = find(curdata(:,4)==5 | curdata(:,4)==7); end
        if r==16, condind = find(curdata(:,4)==6 | curdata(:,4)==8); end
        
        % Condition numbering key (cont.):
        %       17 = SP, H
        %       18 = SP, L
        %       19 = C , H
        %       20 = C , L
        % Collapse across vocoding
        if r==17, condind = find(curdata(:,4)==1 | curdata(:,4)==2); end
        if r==18, condind = find(curdata(:,4)==3 | curdata(:,4)==4); end
        if r==19, condind = find(curdata(:,4)==5 | curdata(:,4)==6); end
        if r==20, condind = find(curdata(:,4)==7 | curdata(:,4)==8); end
        
        
        % Condition numbering key (cont.):
        %       21 = SP
        %       22 = C
        % Averaged by pacing only
        if r==21, condind = find(curdata(:,4)==1 | curdata(:,4)==2 | curdata(:,4)==3 | curdata(:,4)==4); end
        if r==22, condind = find(curdata(:,4)==5 | curdata(:,4)==6 | curdata(:,4)==7 | curdata(:,4)==8); end
        
         % Condition numbering key (cont.):
        %       23 = H
        %       24 = L
        % Averaged by cloze-prob only
        if r==23, condind = find(curdata(:,4)==1 | curdata(:,4)==2 | curdata(:,4)==5 | curdata(:,4)==6); end
        if r==24, condind = find(curdata(:,4)==3 | curdata(:,4)==4 | curdata(:,4)==7 | curdata(:,4)==8); end

         % Condition numbering key (cont.):
        %       25 = V
        %       26 = U
        % Averaged by vocoding only
        if r==25, condind = find(curdata(:,4)==1 | curdata(:,4)==3 | curdata(:,4)==5 | curdata(:,4)==7); end
        if r==26, condind = find(curdata(:,4)==2 | curdata(:,4)==4 | curdata(:,4)==6 | curdata(:,4)==8); end
       
        % All trials
        if r==27, condind = find(curdata(:,4)~=0); end
        conddata = curdata(condind,:);       %subset current condition data
        %------------------------------------------------------------------
        
        
        
        %--- calculate mean pupil/bin for current condition ---------------
        for b=9:100
            procData(currow,b) = nanmean(conddata(:,b));  %fill in procData cols 10-101
        end
        %------------------------------------------------------------------
        
    % End condition for-loop
    end
    
%     for t=1:96 % loop through data for each trial (to find peak pupil location)
%         
%         %--- calculate peak avg dilation  
%         %       and its latency for current condition ---------------------
%         % get begin and end range for peak window
%         % FROM ONSET
%         winStart = 1 + 8;      % Includes all data from bin 11 on (stim onset, to end of trial)
%         winEnd = 92 + 8;    % 
%     %         latencyOffset = 30-21;  % latency is # of bins from sentence onset
% 
%         condarray = curdata(t,winStart:winEnd);   %choose peak from all bins since start of sentence (approx) to last bin
%         peakVal = max(condarray);              %peak after stimuli onset
%         
%         % find bin where peak pupil occurrs
%         zzz = find(condarray==peakVal,1); 
%         if isempty(zzz), 
%             freqArray = +0;
%         else
%             freqArray(bin) = +1;
%         end
%         
%     % End trial for-loop
%     end;

%     fullStart = 1+8;
%     fullEnd = 92+8;
%     condarray2 = procData(currow,fullStart:fullEnd);   %choose peak from all bins since start of sentence (approx) to last bin
%     peakVal2 = max(condarray2);              %peak after stimuli onset
%     if peakVal == peakVal2 
%         procData(currow,101) = 0;
%     else
%         procData(currow,101) = 1;
%     end
        %------------------------------------------------------------------
        
% End of Subject for-loop
end


%=== save output as a csv file, dated =====================================

saveName = input('Give a file name for the output data: ', 's');
cd('../../1Data/5FinalOutput');
csvwrite([saveName date '.csv'], procData);
cd('../../2ProcessingCodes/Processing');
%============================================= Preprocessing complete =====
