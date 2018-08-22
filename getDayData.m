function output = getDayData(data)

mousenum = length(unique(data.mouse));
output.mouse = [];
output.date = [];
output.meanCRAdjAmp = [];
output.CRProb = [];
output.meanAStartleAmp = [];
output.meanURAmp = [];
output.meanHitURAmp = [];
output.meanMissURAmp = [];
output.meanEyelidTrace = [];
output.meanHitEyelidTrace = [];
output.meanMissEyelidTrace = [];
for m = 1:mousenum
    daylist = unique(data.date(data.mouse==m,1));
    
    if m ==1 || m==3
        % CR criterion at 20% because of beta startles for 135 and 138
        crcrit = 0.2;
    else
        crcrit = 0.1;
    end
    
    for d = 1:length(daylist)
        if d==1
            % this will be the day with the tone amplitude adjustments on
            % CS-only trials
            
            % leave this here as a reminder to do something to look at the
            % development of the startle response after CS-alone
            % presentations versus the startle response when the US is
            % paired with the CS
        end
        pairedTrials = find(data.mouse == m & data.date == daylist(d) & ...
            data.c_csdur>0 & data.c_usdur>0);
        
        baseline = nan(length(pairedTrials),1);
        stable = nan(length(pairedTrials),1);
        cradjamp = nan(length(pairedTrials),1);
        uramp = nan(length(pairedTrials),1);
        astartleamp = nan(length(pairedTrials),1);
        for i = 1:length(pairedTrials)
            baseline(i,1) = mean(data.eyelidpos(pairedTrials(i), 1:39));
            cradjamp(i,1) = data.eyelidpos(pairedTrials(i), 76) - baseline(i,1);
            uramp(i,1) = max(data.eyelidpos(pairedTrials(i), 80:100)); % max FEC in the 100 ms after US triggered
            % if the eyelid moves more than 0.1 FEC from baseline, say that
            % there was emough movement in baseline to throw the trial away
            deflectionsDuringBaseline = abs(data.eyelidpos(pairedTrials(i), 1:39) - baseline(i,1));
            if max(deflectionsDuringBaseline)>=0.1
                stable(i,1)=0;
            else
                stable(i,1)=1;
            end
            
            astartleamp(i,1) = max(data.eyelidpos(pairedTrials(i), 40:50)) - baseline(i,1); % the max amplitude in the first 50 ms after the CS is presented
        end
        
        hitTrials = sum(cradjamp>crcrit & stable & baseline<0.3);
        totalTrials = sum(stable & baseline<0.3);
        
        output.mouse(end+1,1) = m;
        output.date(end+1,1) = daylist(d);
        output.meanCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3));
        output.meanAStartleAmp(end+1,1) = mean(astartleamp(stable & baseline<0.3));
        output.meanURAmp(end+1,1) = mean(uramp(stable & baseline<0.3));
        output.meanHitURAmp(end+1,1) = mean(uramp(stable & baseline<0.3 & cradjamp>=0.1));
        output.meanMissURAmp(end+1,1) = mean(uramp(stable & baseline<0.3 & cradjamp<0.1));
        output.CRProb(end+1,1) = hitTrials/totalTrials;
        
        output.meanEyelidTrace(end+1, 1:200) = mean(data.eyelidpos(pairedTrials,:));
        output.meanHitEyelidTrace(end+1, 1:200) = nan(1,200);
        output.meanMissEyelidTrace(end+1, 1:200) = nan(1,200);
        if hitTrials > 0
            output.meanHitEyelidTrace(end, 1:200) = mean(data.eyelidpos(pairedTrials(cradjamp>crcrit & stable & baseline<0.3),:));
        end
        if hitTrials < totalTrials
            output.meanMissEyelidTrace(end, 1:200) = mean(data.eyelidpos(pairedTrials(cradjamp<crcrit & stable & baseline<0.3),:));
        end
    end
end

end