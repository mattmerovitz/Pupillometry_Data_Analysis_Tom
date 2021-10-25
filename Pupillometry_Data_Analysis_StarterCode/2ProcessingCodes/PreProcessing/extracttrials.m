function [screens1,screens2,trials] = extracttrials(dataTable)
    
    % Variables to output
    screens1 = table;
    screens2 = table;
    trials{8} = [];

    % Variables
    numSections = 85;
    trialIndexCol = 3;
    trialnoCol = 2;
    % Col 6 = LeftPupil; Col 7 = RightPupil; Col 8 = SampleMessages
    colsToInclude = [5 6 7 9 10 11 12];
    screensColsToInclude = [9 10 11 12];
    
    % Separate screen data
    screens1Rows = (dataTable{:,trialIndexCol} == 1);
    screens1 = dataTable(screens1Rows, screensColsToInclude);
    
    screens2Rows = (dataTable{:,trialIndexCol} == numSections);
    screens2 = dataTable(screens2Rows, screensColsToInclude);
    
    % Add each trial section to corresponding cell in trials cell array
    for i = 1:size(trials,1)
        disp(i)
        rowsInSection = ((dataTable{:,trialnoCol} == i) && ~(dataTable{:,trialIndexCol} == 1) && ~(dataTable{:,trialIndexCol} == numSections));
        trials{i} = dataTable(rowsInSection, colsToInclude);
    end