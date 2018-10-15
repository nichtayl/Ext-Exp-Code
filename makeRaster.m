function [differences, rasterTimes, checkTheseTimestamps]=makeRaster(triggers, events, ...
    timerange, color, width, makeFig)

differences = [];
checkTheseTimestamps = [];
rasterTimes = cell(length(triggers),1);
for i = 1:length(triggers)
    
    % raster for this trial
    eventsOfInterest = events(abs(events-triggers(i,1))<timerange); % only checks sspks occurring within timerange ms of the CSpk being considered
    rasterTimes{i,1} = eventsOfInterest-triggers(i,1);
    if ~isempty(rasterTimes) && makeFig
        for r = 1:length(rasterTimes{i,1})
            plot([rasterTimes{i,1}(r,1), rasterTimes{i,1}(r,1)], [i-0.25 i+0.25],...
                'Color', color, 'LineWidth', width)
            hold on
        end
    end
    temp = (eventsOfInterest - triggers(i,1));
    differences = [differences;temp];
    if min(abs(differences))==0
        checkTheseTimestamps = [checkTheseTimestamps;triggers(i,1)];
    end
    
end
end