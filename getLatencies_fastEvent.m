%outputs mean & median latencies to event, also number of events in window
%compared to the number of possible windows

function [eventlatency eventdeviation medabsdev, medianval, thisval] = ...
    getLatencies_fastEvent(eventTimes, trialTimes, triggerTimes,...
    sortedPreTime, winOfInterest, bindur, changeDir)

% set up variables so the program doesn't crash when there is no event to
% detect a latency for
eventlatency = NaN;
eventdeviation = NaN;
medabsdev = NaN;
medianval = NaN;
thisval = NaN;

% figure out the difference between trial onset and event onset
% The interval may vary between trials. I don't actually make this code
% capable of dealing with this though because it never happens in my
% dataset...
intervals = nan(length(triggerTimes),1);
trialtimesWithEvent = [];
for i = 1:length(triggerTimes)
    allIntervals = triggerTimes(i) - trialTimes;
    idx = find(allIntervals>0 & allIntervals<1);
    if ~isempty(allIntervals(idx))
        intervals(i,1) = allIntervals(idx);
        trialtimesWithEvent = [trialtimesWithEvent;trialTimes(idx)];
    end
end
if length(triggerTimes)~=length(trialtimesWithEvent)
    disp('events onset registering as >1 s after trial onset... is that ok? if so please modify the code as such.')
    pause
end


% round all the intervals down to the nearest milisecond since all the bin
% times are being input in units of miliseconds
intervals = floor(intervals*1000)/1000;

if length(unique(intervals))>1
    disp('there are unique trial onset and stimulus intervals. this code cannot handle that.')
    pause
end

% calculate the baseline bin positions relative to the trial onset time
% flag this if an interval value is less than 0.2 s because then there will
% be a problem here
if min(intervals)<0.2
    disp('an event begins less than 0.2 s after trial onset, there will be a baseline bin overlapping with the event period as the code stands right now. please fix. you will have to change the getHistLineVals function as well as this one.')
    pause
end

% this will give you binned activity where 0 is the trigger onset time, NOT the trial
% onset time
[eventdiffs, eventRasterTimes, checkTheseTimestamps]=makeRaster(triggerTimes, ...
    eventTimes, 0.6, [1 1 0], 1, 0);
binedges = [-1*(0.4+0.2):bindur:0.4+0.2];
[yvals, ymax, binvalues]=getHistLineVals('frequency', eventdiffs, triggerTimes,...
    binedges, bindur, eventTimes);



% find the 400 ms worth of bins around the trial onset. these will be the
% baseline bins.
baselineVals = [];
binedgesRelativeToTrialOnset = binedges + intervals(1); % 0 relative to trigger start should be 0+intervals(i) relative to trial start
baselineWindowFirstBin = find(abs(binedgesRelativeToTrialOnset--0.2)<0.001);
baselineWindowLastBin = find(abs(binedgesRelativeToTrialOnset-0.2)<0.001);
baselineVals = binvalues(baselineWindowFirstBin:baselineWindowLastBin,1);


% find the bin that the stimulus starts at
% this assumes that you are using a bin duration such that the stimulus
% onset can equal bin onsets
stimStartBin = find(binedges==0); % if there is no interval, this is the first stimulus in the trial so you want to find the bin where t=0, if there is an interval you want to find the bin where t=interval

for i = stimStartBin:length(binedges)-1
    if binedges(i) > winOfInterest
        break
    end
    [hasResponse, outlyingness, outlyingdir, thisdev, medabsdev, medianval] = ...
        isOutlier_MADMethod([baselineVals',binvalues(i)]); % add the value of interest to the end of the sent vector so the function knows what to do with it
    if hasResponse && outlyingdir==changeDir
        eventlatency = binedges(i);
        eventdeviation = thisdev;
        thisval = binvalues(i);
        %            figure
        %            bincenters = binedges(1:end-1)-(bindur/2);
        %            bar(bincenters, binvalues)
        %            hold on
        %            plot([bincenters(i) bincenters(i)], [0 binvalues(i)], 'Color', [1 0 0], 'LineWidth', 2)
        %            pause
        break
    end
end

end