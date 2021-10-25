function subjScores = getxls(sheetEnd, xlsRange)

numSubjs = 20;
subjScores{numSubjs,2} = [];

[fileName,pathName] = uigetfile('*.*', 'Choose File to Process');
fileFullPath = strcat(pathName, fileName);
        
for i = 1:sheetEnd

    switch nargin
        case 2
            [num,txt,raw] = xlsread(fileFullPath, i, xlsRange);
        case 1
            [num,txt,raw] = xlsread(fileFullPath, i);
    end
    
    headers = raw(1,:);
    subjScores{i,1} = num;
    subjScores{i,2} = headers;

end