%outputs mean & median latencies to event, also number of events in window
%compared to the number of possible windows

function [latencySummary] = ...
    getLatencies_lowProbEvent(eventTimes, winStart, winEnd)

    eventlatencies = nan(length(winStart), 1);
    for i = 1:length(winStart)
        winTimes = eventTimes(eventTimes>=winStart(i,1)...
            & eventTimes<=winEnd(i,1),1);
        if ~isempty(winTimes)
            eventlatencies(i,1) = winTimes(1)-winStart(i,1); % take the earliest time in the window, assumes that the eventTimes are coming in sorted
        end
    end
    
    latencySummary(1,1) = nanmean(eventlatencies);
    latencySummary(1,2) = nanmedian(eventlatencies);
    latencySummary(1,3) = sum(~isnan(eventlatencies));
    latencySummary(1,4) = length(eventlatencies);
    
end