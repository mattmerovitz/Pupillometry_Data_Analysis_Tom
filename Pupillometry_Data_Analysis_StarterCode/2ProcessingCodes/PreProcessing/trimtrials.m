function trials = trimtrials(trials)
    
    % Variables
    sampleMessageCol = 'SAMPLE_MESSAGE';
    pacingCol = 1;

    % For each trial
    for i = 1:size(trials,2)
        disp(i)      %% <-- output to see progress of function
        
        % Select one trial from cell array
        trial = trials{i};

        % Add column of zeros to trial data
        s = size(trial);
        newCol = zeros(s(1),1);
        trial = [trial array2table(newCol)];
        
        % Label each row with its section in the trial
        section = 0;
        for j = 1:s(1)
            if  strncmpi(trial{j,sampleMessageCol}, '.',1)~=1
                section = section + 1;
            end
            trial{j,s(2)+1} = section;
        end

        if strncmpi(trial{1,pacingCol}, 'S',1) == 1
            % Keep only data while stim is playing, for each of the
            % separate chunks
            include = mod(trial{:,s(2)+1},2) == 1;
            trial = trial(include,:);
        end
        
        % Update cell array with trimmed trial data
        trials{i} = trial;
    end