function [screens1,screens2,trials] = extracttrials(dataTable)
    
    % Variables to output
    screens1 = table;
    screens2 = table;
    trials{96} = [];

    % Variables
    numSections = 98;
    trialIndexCol = 3;
    % Col 6 = LeftPupil; Col 7 = RightPupil; Col 8 = SampleMessages
    colsToInclude = [6 7 8];
    screensColsToInclude = [6 7 8];
    
    % Separate screen data
    screens1Rows = (dataTable{:,trialIndexCol} == 1);
    screens1 = dataTable(screens1Rows, screensColsToInclude);
    
    screens2Rows = (dataTable{:,trialIndexCol} == 98);
    screens2 = dataTable(screens2Rows, screensColsToInclude);
    
    % Add each trial section to corresponding cell in trials cell array
    for i = 2:numSections-1
        disp(i)
        rowsInSection = (dataTable{:,trialIndexCol} == i);
        trials{i-1} = dataTable(rowsInSection, colsToInclude);
    end