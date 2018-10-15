%outputs mean & median latencies to event, also number of events in window
%compared to the number of possible windows

function [eventlatency eventdeviation medabsdev, medianval, thisval] = ...
    getLatencies_fastEvent(eventTimes, triggerTimes, sortedPreTime, windur, bindur, changeDir)

    winwidth = (-1*sortedPreTime) + 0.2; % assumes there are 0.2 s in the trial before the stimulus is presented and that the stimulus occurs at time 0 in the trial
    [eventdiffs, eventRasterTimes, checkTheseTimestamps]=makeRaster(triggerTimes, ...
        eventTimes, 0.4, [1 1 0], 1, 0);
    binedges = [-0.4:bindur:0.4];
    [yvals, ymax, binvalues]=getHistLineVals('frequency', eventdiffs, triggerTimes,...
        binedges, bindur, eventTimes);
    baselineWinStartBin = 1;
    baselineWinEndBin = find(binedges==0);
    baselineVals = binvalues(baselineWinStartBin:baselineWinEndBin-1);
    for i = baselineWinEndBin:length(binedges)-1
       if binedges(i) > windur
           break
       end
       [hasResponse, outlyingness, outlyingdir, thisdev, medabsdev, medianval] = isOutlier_MADMethod([baselineVals',binvalues(i)]); % add the value of interest to the end of the sent vector so the function knows what to do with it
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