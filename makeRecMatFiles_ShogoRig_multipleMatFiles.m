%%% this is for outputting more usable arrays of spike times, trial times,
%%% etc for PC recordings from Shogo's recording rig

function [SS_times, CSpk_times] = makeRecMatFiles_ShogoRig_multipleMatFiles(thisFile, sscodes, cspkcodes, sscspkcodes,...
    oddcspkcodes, oddcspktimefileexists)

SS_idx = [];
CSpk_idx = [];

SS_times = [];
CSpk_times = [];

tdtTrials.LAmp= [];
tdtTrials.LDur = [];
tdtTrials.UDur = [];
tdtTrials.LTime = [];
tdtTrials.UTime = [];
tdtTrials.trltime = [];

for f = 1:length(thisFile)
    %% load file
    filename = char(thisFile(f));
    filename = string(filename);
    load(filename)
    filenamebeg = filename(1:17);
    
    
    %% get SSpk times
    SS_idx = [];
    for idx = 1:length(sscodes)
        SS_idx = [SS_idx; find(nw_17.codes(:,1) == sscodes(idx))];
    end
    if ~isempty(sscspkcodes)
        for idx=1:length(sscspkcodes)
            SS_idx = [SS_idx; find(nw_17.codes(:,1) == sscspkcodes(idx))];
        end
    end
    temp = nw_17.times(SS_idx, 1);
    temp = sort(temp);
    SS_times = [SS_times; temp];
    
    %% get CSpk times
    % normally triggered CSpks
    CSpk_idx = [];
    for idx = 1:length(cspkcodes)
        CSpk_idx = [CSpk_idx; find(nw_17.codes(:,1) == cspkcodes(idx))];
    end
    temp = nw_17.times(CSpk_idx, 1);
    temp = sort(temp);
    CSpk_times = [CSpk_times; temp];
    
    % badly triggered CSpks
    oddCSpk_idx = [];
    badCSpkCodes = [sscspkcodes; oddcspkcodes];
    if ~isempty(badCSpkCodes)
        if isempty(oddcspktimefileexists)
            %% user must interact with script for this part to manually get the CSpk times
            oddCSpk_idx = [];
            for idx = 1:length(badCSpkCodes)
                oddCSpk_idx =[oddCSpk_idx; find(nw_17.codes(:,1) == badCSpkCodes(idx))];
            end
            oddCSpk_times = nw_17.times(oddCSpk_idx,1);
            oddCSpk_times = sort(oddCSpk_times);
            
            waveformStartIndices = nan(length(oddCSpk_times),1);
            for i = 1:length(oddCSpk_times)
                waveformStartIndices(i,1)=find(Spk2_01.times == oddCSpk_times(i,1));
            end
            
            % want to look at 8 ms after the waveform start, so plot these
            % values and then ask user to get the waveform onset time
            
            h1 = figure;
            set(h1, 'Position', [10 600 1000 400])
            CSpktime = [];
            for i = 1:length(waveformStartIndices)
                plot(Spk2_01.times(waveformStartIndices(i):waveformStartIndices(i)+192,1),...
                    Spk2_01.values(waveformStartIndices(i):waveformStartIndices(i)+192,1))
                title(num2str(i))
                input = inputdlg('CSpk start time?');
                input = str2double(input);
                while isnan(input) || ...
                        input < Spk2_01.times(waveformStartIndices(i),1) || ...
                        input > Spk2_01.times(waveformStartIndices(i)+192,1)
                    if isnan(input)
                        input = inputdlg('Please input CSpk start time using 0-9 and . characters');
                    else
                        input = inputdlg('Please input a CSpk start time within viewed window');
                    end
                    input = str2double(input);
                end
                CSpktime = [CSpktime; input];
            end
            
            indices = 1:length(waveformStartIndices);
            data = [indices',CSpktime];
            headers = {'Index','CSpk Time'};
            datacell = num2cell(data);
            writeme = [headers; datacell];
            filename = strcat(filenamebeg, num2str(f), '_oddCSpkTimes.xlsx');
            xlswrite(filename, writeme)
            close all
        else
            filename = strcat(cd, '\', filenamebeg, num2str(f), '_oddCSpkTimes.xlsx');
            spreadsheet = xlsread(filename);
            CSpktime = spreadsheet(:,2); % I put the times in column 2 and the indices from oddCSpk_times into column 1
        end
        
        %% integrate the data into the existing CSpk time list
        CSpk_times = [CSpk_times;CSpktime];
        CSpk_times = sort(CSpk_times);
        
        %% get TDT behavior data (timestamps)
        % need to figure out which trials had laser, which trials had puff, which
        % trials had laser and puff
        
        % maybe the best thing would be to go through TrlN and just figure out what
        % events go with what trials
        
        lamptemp = nan(length(TrlN.times),1);
        ldurtemp = nan(length(TrlN.times),1);
        udurtemp = nan(length(TrlN.times),1);
        ltimetemp = nan(length(TrlN.times),1);
        utimetemp = nan(length(TrlN.times),1);
        for i = 1:length(TrlN.times)-1
            lamptemp(i,1) = str2double(LAmp.text(LAmp.times>=TrlN.times(i) & LAmp.times<=TrlN.times(i+1),:));
            ldurtemp(i,1) = str2double(LDur.text(LDur.times>=TrlN.times(i) & LDur.times<=TrlN.times(i+1),:));
            udurtemp(i,1) = str2double(UDur.text(UDur.times>=TrlN.times(i) & UDur.times<=TrlN.times(i+1),:));
            
            temp = LDur.times(LDur.times>=TrlN.times(i) & LDur.times<=TrlN.times(i+1),:);
            if ~isempty(temp)
                ltimetemp = temp;
            end
            temp = UDur.times(UDur.times>=TrlN.times(i) & UDur.times<=TrlN.times(i+1),:);
            if ~isempty(temp)
                utimetemp(i,1) = temp;
            end
        end
        lamptemp(length(TrlN.times),1) = str2double(LAmp.text(LAmp.times>=TrlN.times(end),:));
        ldurtemp(length(TrlN.times),1) = str2double(LDur.text(LDur.times>=TrlN.times(end),:));
        udurtemp(length(TrlN.times),1) = str2double(UDur.text(UDur.times>=TrlN.times(end),:));
        ltimetemp(length(TrlN.times),1) = UDur.times(UDur.times>=TrlN.times(end),:);
        utimetemp(length(TrlN.times),1) = UDur.times(UDur.times>=TrlN.times(end),:);
        
        
        tdtTrials.LAmp = [tdtTrials.LAmp; lamptemp];
        tdtTrials.LDur = [tdtTrials.LDur; ldurtemp];
        tdtTrials.UDur = [tdtTrials.UDur; udurtemp];
        tdtTrials.LTime = [tdtTrials.LTime; ltimetemp];
        tdtTrials.UTime = [tdtTrials.UTime; utimetemp];
        tdtTrials.trltime = [tdtTrials.trltime; TrlN.times];
    end
end

%% write spike MAT files
filename = strcat(filenamebeg, 'SSts.mat');
save(filename, 'SS_times') % includes poorly sorted spikes

filename = strcat(filenamebeg, 'CSpkts.mat');
save(filename, 'CSpk_times') % includes poorly sorted spikes


%% write behavior data MAT files
filename = strcat(filenamebeg, 'trialInfo.mat');
headers = {'Trial onset', 'Laser Dur', 'Laser Amp', 'Laser Onset', 'Puff Onset', 'Puff Dur'};
data = [tdtTrials.trltime, tdtTrials.LDur, tdtTrials.LAmp, tdtTrials.LTime, tdtTrials.UTime, tdtTrials.UDur];
datacells = num2cell(data);
writeme = [headers; datacells];
save(filename, 'writeme')

end
