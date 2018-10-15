function [eventlatencies] = ...
    getLatenciesFromRaster_lowProbabilityEvent(eventRasterTimes, winStart, winEnd)

    [m n] = size(eventRasterTimes);
    eventlatencies = nan(m, 4);
    for i = 1:m
        trialsThisDayCSpk = eventRasterTimes{m,1};
        
        thisDayLatenciesCSpk = nan(length(trialsThisDayCSpk), 1);
        
        for j = 1:length(trialsThisDayCSpk)
            thisTrialCSpk = trialsThisDayCSpk(j,1);
            posvalsCSpk = thisTrialCSpk(thisTrialCSpk > winStart & ...
                thisTrialCSpk < winEnd, 1);
            if ~isempty(posvalsCSpk)
                thisDayLatenciesCSpk(j,1) = posvalsCSpk(1);
            end
            clear posvalsCSpk
        end
        
        eventlatencies(i,1) = nanmean(thisDayLatenciesCSpk);
        eventlatencies(i,2) = nanmedian(thisDayLatenciesCSpk);
        eventlatencies(i,3) = sum(~isnan(thisDayLatenciesCSpk));
        eventlatencies(i,4) = length(thisDayLatenciesCSpk);
    end
    
end