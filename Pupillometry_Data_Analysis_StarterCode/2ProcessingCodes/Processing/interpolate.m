function [curPupils,sbjdataout] = interpolate(numBlinks, curPupils, blinkProp, sbjdataout)

    % Check if there is too much blinking; if not, do steps below
    % If there is toom much blinking, go to elseif
    if numBlinks/length(curPupils) <= blinkProp && sum(isnan(curPupils)) ~= length(curPupils)

    %--- linear interpolation to fill in NaNs --------
        for ss=1:length(curPupils)

    %--- look for beginning of a blink ---------------
            if isnan(curPupils(ss))
                
                x1 = ss; 
                x2 = ss;
                
                for si=ss:length(curPupils)

    %--- check for end of blink ----------------------
                    if curPupils(si) > 0 || si == length(curPupils)
                        x2 = si;
                        break;
                    end
                    
                end

                if ss == 1
                    y1 = curPupils(x1);   
                else
                    y1 = curPupils(x1-1);
                end
                y2 = curPupils(x2);

                if isnan(y1), y1=y2; end
                if isnan(y2), y2=y1; end

    %--- linear interpolation-------------------------
                for x=x1:x2
                    curPupils(x) = y1 + ( ( (y2-y1)/(x2-x1) )*(x-x1) );
                end
            end
        end
            % If there is too much blinking
    elseif sum(isnan(curPupils)) == length(curPupils)
        
        sbjdataout(1,100) = NaN;
        
    end