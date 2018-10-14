function [hasResponse, realValOutlyingness] = checkForResponse_frequency(spikeTimes, trialTimes,...
    eventTimes, preTrialWin, winOfInterest, makeFig)

n = 500;

% make n random windows within the pre-stimulus window (preTrialWin + 0.2 s),
% then use those bins as windows of interest for control "trials" and find
% the probability of there being an increased frequency response in those bins across the same
% number of trials as sent to the function
relativeWinStarts = nan(n,1);
maxRelativeWinStart = (preTrialWin+0.2-winOfInterest);
for i = 1:n
    relativeWinStarts(i,1) = rand()*maxRelativeWinStart;
end

wasSpike = nan(length(trialTimes), n+1); % num trials x n+1 array of whether there was a spike in the arbitrary window that trial (n+1 so can add the real window at the end)
for i = 1:length(trialTimes)
    % do the fake trials
    for j = 1:n
        thiswinbeg = trialTimes(i,1) + 0.2 - relativeWinStarts(j,1);
        spikesThisWin = spikeTimes>=thiswinbeg & spikeTimes<=(thiswinbeg + winOfInterest);
        wasSpike(i,j) = sum(spikesThisWin); % doing it like this so can have a frequency option later
        clear thiswinbeg spikesThisWin
    end
    
    % do the real trials
    if isnan(eventTimes(i)) % there was no event on this trial
        wasSpike(i, n+1) = NaN;
    else
        thiswinbeg = eventTimes(i,1);
        thiswinend = thiswinbeg + winOfInterest;
        spikesThisWin = spikeTimes>=thiswinbeg & spikeTimes<=thiswinend;
        wasSpike(i, n+1) = sum(spikesThisWin);
        clear thiswinbeg thiswinend spikesThisWin
    end
end

rowsOfInterest = ~isnan(wasSpike(:,n+1));
binFreq = wasSpike(rowsOfInterest, :)/winOfInterest;
meanBinFreq = mean(binFreq);

if makeFig
    % bin spikeProbs into bins from 0:0.1:1 probability
    bindur = 2;
    binedges = 0:bindur:300;
    bincounts = zeros(1, length(binedges)-1);
    for i = 1:length(binedges)-2
        freqsThisRange = meanBinFreq(:,1:n)>=binedges(i) & meanBinFreq(:,1:n)<binedges(i+1);
        bincounts(1,i) = bincounts(1,i) + sum(freqsThisRange);
    end
    freqsThisRange = meanBinFreq(:,1:n)>=binedges(end-1) & meanBinFreq(:,1:n)<=binedges(end);
    bincounts(1,end)=bincounts(1,end)+sum(freqsThisRange);
    bincenters = binedges(1:end-1) + (bindur/2);
    
    figure
    bar(bincenters, bincounts)
    hold on
    ymax = max(bincounts)*1.1;
    plot([meanBinFreq(1,n+1) meanBinFreq(1,n+1)], [0 ymax], 'Color', 'r')
    ylim([0 ymax])
    
end

% compute outlyingness
% see Leys et al., 2013 for description of this method
medabsdev = 1.4826 * median(abs(meanBinFreq - median(meanBinFreq)));
realValOutlyingness = abs((meanBinFreq(1,n+1) - median(meanBinFreq))/medabsdev);
if realValOutlyingness >= 3
    hasResponse = 1;
else
    hasResponse = 0;
end

end