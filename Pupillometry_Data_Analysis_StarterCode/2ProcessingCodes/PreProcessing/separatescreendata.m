function [blackScreen,whiteScreen] = separatescreendata(screenData, sectionCol, dataLength)
    
    % If all messages were included
    % blackScreen = section #2, whiteScreen = section #3
    if screenData{dataLength, sectionCol} == 4
        
        % Save data from black screen
        blackInclude = screenData{:,sectionCol} == 2;
        blackScreen = screenData(blackInclude,1:2);
        
        % Save data from white screen
        whiteInclude = screenData{:,sectionCol} == 3;
        whiteScreen = screenData(whiteInclude,1:2);
        
    % If a message was lost
    % both screens = section 1, split in half
    elseif screenData{dataLength, sectionCol} == 3;
        
        display('SCREEN DATA MESSAGE LOST')
        
        % Isolate screen data
        include = screenData{:,sectionCol} == 2;
        bothScreens = screenData(include,:);
        
        % Find row half-way through screen data
        bsSize = size(bothScreens);
        numSamples = bsSize(1);
        halfwayPoint = int32(numSamples/2);
        
        % Data before half-way point is black screen
        blackScreen = bothScreens(1:halfwayPoint,1:2);
%         for i = 1:halfPoint;
%             if mod(i,1000) == 0;
%                 display(i)      %% <-- output to see progress of function
%             end;
%             blackScreen(i,:) = bothScreens(i,:);
%         end;
        
        % Data after half-way point is white screen
        whiteScreen = bothScreens(halfwayPoint+1:end,1:2);
%         for i = halfPoint+1:numSamples;
%             if mod(i,1000) == 0;
%                 display(i)      %% <-- output to see progress of function
%             end; 
%             whiteScreen(i-halfPoint,:) = bothScreens(i,:);
%             % Change section number to white screen section number
%             whiteScreen{i-halfPoint,4} = 2;
%         end;
        
    % If more than one message is lost, riase and error
    else
        error('Cannot detect number of screens. More than one message lost in screen data')
    end;