function [hasResponse, realValOutlyingness, outlyingDir, resp, binme] = ...
    checkForResponse_chooseMetric(spikeTimes, trialTimes,...
    eventTimes, preTrialWin, winOfInterest, type, makeFig)

n = 500;

% make n random windows within the pre-stimulus window (preTrialWin + 0.2 s),
% then use those bins as windows of interest for control "trials" and find
% the probability of there being a response in those bins across the same
% number of trials as sent to the function
relativeWinStarts = nan(n,1);
maxRelativeWinStart = (abs(preTrialWin)+0.2-winOfInterest);

% get window onset relative to stimulus onset time, then subtract 0.2 to
% get window onset relative to trial onset time
for i = 1:n
    relativeWinStarts(i,1) = (rand()*maxRelativeWinStart)-0.2;
end

wasSpike = nan(length(trialTimes), n+1); % num trials x n+1 array of whether there was a spike in the arbitrary window that trial (n+1 so can add the real window at the end)
eventidx = 1;
for i = 1:length(trialTimes)
    % do the fake trials
    for j = 1:n
        thiswinbeg = trialTimes(i,1) + - relativeWinStarts(j,1);
        spikesThisWin = spikeTimes>=thiswinbeg & spikeTimes<=(thiswinbeg + winOfInterest);
        wasSpike(i,j) = sum(spikesThisWin); % doing it like this so can have a frequency option later
        clear thiswinbeg spikesThisWin
    end
    
    % do the real trials
    if eventidx > length(eventTimes)
        wasSpike(i, n+1) = NaN;
    elseif (eventTimes(eventidx,1) < trialTimes(i,1)) || ...
            (eventTimes(eventidx,1) > trialTimes(i,1) + 1)
        wasSpike(i, n+1) = NaN;
    else
        thiswinbeg = eventTimes(eventidx,1);
        thiswinend = thiswinbeg + winOfInterest;
        spikesThisWin = spikeTimes>=thiswinbeg & spikeTimes<=thiswinend;
        wasSpike(i, n+1) = sum(spikesThisWin);
        clear thiswinbeg thiswinend spikesThisWin
        
        eventidx = eventidx + 1;
    end
end

rowsOfInterest = ~isnan(wasSpike(:,n+1));

if strcmpi(type,'probability')
    hasSpike = wasSpike(rowsOfInterest,:)>=1;
    
    spikeProbs = sum(hasSpike)/sum(rowsOfInterest);
    
    resp = spikeProbs(1,n+1);
    
    binme = spikeProbs;
    
    binmax = 1;
    bindur = 0.1;
elseif strcmpi(type,'frequency')
    rowsOfInterest = ~isnan(wasSpike(:,n+1));
    binFreq = wasSpike(rowsOfInterest, :)/winOfInterest;
    meanBinFreq = mean(binFreq);
    
    resp = meanBinFreq(1,n+1);
    
    binme = meanBinFreq;
    
    binmax = 300;
    bindur = 2;
else
    disp('invalid type entered')
    pause
end

if makeFig
    % bin spikeProbs into bins from 0:0.1:1 probability
    binedges = 0:bindur:binmax;
    bincounts = zeros(1, length(binedges)-1);
    for i = 1:length(binedges)-2
        binsThisRange = binme(:,1:n)>=binedges(i) & binme(:,1:n)<binedges(i+1);
        bincounts(1,i) = bincounts(1,i) + sum(binsThisRange);
    end
    binsThisRange = binme(:,1:n)>=binedges(end-1) & binme(:,1:n)<=binedges(end);
    bincounts(1,end)=bincounts(1,end)+sum(binsThisRange);
    bincenters = binedges(1:end-1) + (bindur/2);
    
    colordef white
    figure
    bar(bincenters, bincounts)
    hold on
    ymax = max(bincounts)*1.1;
    plot([binme(1,n+1) binme(1,n+1)], [0 ymax], 'Color', 'r')
    ylim([0 ymax])
    
end


[hasResponse, realValOutlyingness, outlyingDir, thisdev, medabsdev, medianval] = isOutlier_MADMethod(binme);

end