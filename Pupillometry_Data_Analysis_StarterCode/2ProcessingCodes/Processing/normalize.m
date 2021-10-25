function newPupils = normalize(maxPupil, minPupil, newPupils, tmod, baseline, zscore)
    if (zscore)
        
        disp("Not yet implemented. Please change the zscore variable and try again.")
    
    else
        
        % get baseline pupil size (sentence onset)
        targetPupil = mean(newPupils(1:baseline));       % mean pupil size over baseline period
        targetPupil = ((targetPupil-minPupil)/(maxPupil-minPupil))*100;

        % normalize to dynamic range, baseline from sentence onset
        for i = 1:length(newPupils)
            newPupils(i) = (((newPupils(i)-minPupil)/(maxPupil-minPupil))*100)-targetPupil;
        end

        % buffer data to align to sentence end
        if isnan(tmod)
            newPupils(:) = NaN;
        else
            buffer = nan(tmod,1);
            newPupils = vertcat(buffer, newPupils);
        end
        
    end
     