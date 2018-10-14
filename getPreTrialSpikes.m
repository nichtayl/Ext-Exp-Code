function [sortedSpikeTimes, preTrialSpikeCount, totalTime, FR] = ...
    getPreTrialSpikes(spiketimes, trialtimes, pretrialwinsorted)

% figure out relevant spike windows
winbegs = trialtimes - pretrialwinsorted;
winends = trialtimes + 0.2; % 200 ms before stimuli presented on a trial
totalTime = (pretrialwinsorted + 0.2) * length(trialtimes);

% count the number of spikes in each window & save the spike times
preTrialSpikeCount = 0;
sortedSpikeTimes = [];
for i = 1:length(winbegs)
    
    thiswinbeg = winbegs(i,1);
    thiswinend = winends(i,1);
    
    spikesinwin = spiketimes>=thiswinbeg & spiketimes<=thiswinend;
    preTrialSpikeCount = preTrialSpikeCount + sum(spikesinwin);
    if sum(spiketimes(spikesinwin))>0
        sortedSpikeTimes = [sortedSpikeTimes; spiketimes(spikesinwin)];
    end
    
    clear spikesinwin thiswinbeg thiswinend
end

FR = preTrialSpikeCount/totalTime;

end