function [blackScreen1, whiteScreen1, blackScreen2, whiteScreen2] = extractscreens(screens1, screens2)
    
    % Variables to output
    blackScreen1 = table;
    whiteScreen1 = table;
    blackScreen2 = table;
    whiteScreen2 = table;

    % Variables
    sampleMessageCol = 3;
    s1 = size(screens1);
    s2 = size(screens2);
    sectionCol = s1(2)+1;
    
    % Add column of zeros to screen data
    newCol1 = zeros(s1(1),1);
    screens1 = [screens1 array2table(newCol1)];
    
    newCol2 = zeros(s2(1),1);
    screens2 = [screens2 array2table(newCol2)];
    
    % Label each row with its section in the screen data
    section = 0;
    for i = 1:s1(1);
        if mod(i,1000) == 0;
            display(i)      %% <-- output to see progress of function
        end;
        if  strncmpi(screens1{i,sampleMessageCol}, '.',1)~=1;
            section = section + 1;
        end;
        screens1{i,sectionCol} = section;
    end;
    
    section = 0;
    for i = 1:s2(1);
        if mod(i,1000) == 0;
            display(i)      %% <-- output to see progress of function
        end;
        if  strncmpi(screens2{i,sampleMessageCol}, '.',1)~=1;
            section = section + 1;
        end;
        screens2{i,sectionCol} = section;
    end;
    
%     % If all messages were included
%     % blackScreen = section1, whiteScreen = section2
    [blackScreen1, whiteScreen1] = separatescreendata(screens1, sectionCol, s1(1));
    [blackScreen2, whiteScreen2] = separatescreendata(screens2, sectionCol, s2(1));

end

