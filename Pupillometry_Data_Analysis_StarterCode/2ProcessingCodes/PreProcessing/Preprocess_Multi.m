% ----------------------------------
% ----   Data Analysis Script   ----
% ----         For PrP          ----
% ----  Created by Alex Kinney  ----
% ----------------------------------


%==========================================================================
% Script Start/Setup
%==========================================================================

clear;

% Variables


% Open .txt file with data and load into scalar structure
[fileName,pathName] = uigetfile('*.*', 'Choose File to Process','MultiSelect', 'on');
disp('You selected ' + string(pathName) + string(fileName))

if ischar(fileName)     % if only one file was selected, convert to cell array
    fileName = cellstr(fileName);
end

numFiles = length(fileName);

for f = 1:numFiles

    fileFullPath = strcat(pathName, fileName{f});
    data = tdfread(fileFullPath);
    dataCols = fieldnames(data);
    dataTable = struct2table(data);

    % Create cell array with data separated into trials
    [screens1, screens2, trials] = extracttrials(dataTable);
    % Cut out unnecessary parts of trials
    trimmedTrials = trimtrials(trials);
    % Split up screen data into black and white screens
    [blackScreen1, whiteScreen1, blackScreen2, whiteScreen2] = extractscreens(screens1, screens2);

    % Save screen and trial data
    cd('../../1Data/4ExtractedData');
    save(fileName{f}(1:9), 'blackScreen1', 'whiteScreen1', 'blackScreen2', 'whiteScreen2', 'trimmedTrials');
    cd('../../2ProcessingCodes/PreProcessing');
    
end
