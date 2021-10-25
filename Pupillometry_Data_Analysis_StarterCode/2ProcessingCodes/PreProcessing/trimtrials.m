function trials = trimtrials(trials)
    
    % Variables
    sampleMessageCol = 3;

    % For each trial
    for i = 1:96 %*******THIS SHOULD CHANGE TO 1:NUM_PARTICIPANTS********
        disp(i)      %% <-- output to see progress of function
        
        % Select one trial from cell array
        trial = trials{i};

        % Add column of zeros to trial data
        s = size(trial);
        newCol = zeros(s(1),1);
        trial = [trial array2table(newCol)];
        
        % Label each row with its section in the trial
        section = 0;
        for j = 1:s(1);
            if  strncmpi(trial{j,sampleMessageCol}, '.',1)~=1;
                section = section + 1;
            end;
            trial{j,s(2)+1} = section;
        end;

        % Keep only data while stim is playing, and waits before/after stim
        include = trial{:,4} == 2 | trial{:,4} == 3 | trial{:,4} == 4;
        trial = trial(include,:);
        
        % Update cell array with trimmed trial data
        trials{i} = trial;
    end;
    