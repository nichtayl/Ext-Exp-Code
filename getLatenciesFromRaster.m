function [sslatencies, cspklatencies] = ...
    getLatenciesFromRaster(ssRasterTimes, cspkRasterTimes, winStart, winEnd)

    [m n] = size(ssRasterTimes);
    sslatencies = nan(m, 4);
    cspklatencies = nan(m, 4);
    for i = 1:m
        trialsThisDaySS = ssRasterTimes{m,1};
        trialsThisDayCSpk = cspkRasterTimes{m,1};
        
        thisDayLatenciesSS = nan(length(trialsThisDaySS), 1);
        thisDayLatenciesCSpk = nan(length(trialsThisDayCSpk), 1);
        
        for j = 1:length(trialsThisDaySS)
            thisTrialSS = trialsThisDaySS{j,1};
            posvalsSS = thisTrialSS(thisTrialSS > winStart & ...
                thisTrialSS < winEnd, 1);
            if ~isempty(posvalsSS)
                thisDayLatenciesSS(j,1) = posvalsSS(1);
            end
            clear posvalsSS
            
            thisTrialCSpk = trialsThisDayCSpk{j,1};
            posvalsCSpk = thisTrialCSpk(thisTrialCSpk > winStart & ...
                thisTrialCSpk < winEnd, 1);
            if ~isempty(posvalsCSpk)
                thisDayLatenciesCSpk(j,1) = posvalsCSpk(1);
            end
            clear posvalsCSpk
        end
        
        sslatencies(i,1) = nanmean(thisDayLatenciesSS);
        sslatencies(i,2) = nanmedian(thisDayLatenciesSS);
        sslatencies(i,3) = sum(~isnan(thisDayLatenciesSS));
        sslatencies(i,4) = length(thisDayLatenciesSS);
        
        cspklatencies(i,1) = nanmean(thisDayLatenciesCSpk);
        cspklatencies(i,2) = nanmedian(thisDayLatenciesCSpk);
        cspklatencies(i,3) = sum(~isnan(thisDayLatenciesCSpk));
        cspklatencies(i,4) = length(thisDayLatenciesCSpk);
    end
    
end