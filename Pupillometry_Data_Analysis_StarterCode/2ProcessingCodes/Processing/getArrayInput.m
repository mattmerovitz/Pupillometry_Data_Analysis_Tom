function includeVec = getArrayInput(dataHeaders)
    
    str1 = 'Enter column vector for which columns to include. Columns are:\n';
    headerStr = strjoin(dataHeaders, ' ');
    str2 = '\n-> ';
    
    inputStr = strcat(str1, headerStr, str2);
    includeVec = input(inputStr);
    
    if length(dataHeaders) ~= length(includeVec)
        'Incorrect input. Try Again.'
        includeVec = getArrayInput(dataHeaders);
    end
    