function [maxPupil, minPupil] = getScreenMaxMin(blackScreen, whiteScreen)
    % Takes in trimmed black screen and white screen dynamic range
    % measurements, and calculates the upper (maxPupil) and lower 
    % (minPupil) bounds of the dynamic range
    
    blackScrnSize = size(blackScreen);
    blackScr = zeros(blackScrnSize(1),1);
    for i=1:length(blackScr)
        blackScr(i) = str2double(table2array(blackScreen(i,:)));
    end
    
    whiteScrnSize = size(whiteScreen);
    whiteScr = zeros(whiteScrnSize(1),1);
    for i=1:length(whiteScr)
        whiteScr(i) = str2double(table2array(whiteScreen(i,:)));
    end
    
    %~~~~~ deblink & take mean of plateau ~~~~~
    [maxPupil,minPupil] = pupRange(blackScr,whiteScr);
    
end

