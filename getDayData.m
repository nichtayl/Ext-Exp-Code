function output = getDayData(data, timeVector, crcriteria)

mousenum = length(unique(data.mouse));
output.mouse = [];
output.date = [];
output.meanCRAdjAmp = [];
output.hitCRAdjAmp = [];
output.missCRAdjAmp = [];
output.CRProb = [];
output.meanAStartleAmp = [];

output.meanURAmp = [];
output.meanURIntegral = [];
output.meanHitURAmp = [];
output.meanHitURIntegral = [];
output.meanMissURAmp = [];
output.meanMissURIntegral = [];
output.meanURAmpAdj = [];
output.meanURIntegralAdj = [];
output.meanHitURAmpAdj = [];
output.meanHitURIntegralAdj = [];
output.meanMissURAmpAdj = [];
output.meanMissURIntegralAdj = [];

output.meanEyelidTrace = [];
output.semEyelidTrace = [];
output.meanHitEyelidTrace = [];
output.semHitEyelidTrace = [];
output.meanMissEyelidTrace = [];
output.semMissEyelidTrace = [];
output.meanEyelidTraceAdj = [];
output.semEyelidTraceAdj = [];
output.meanHitEyelidTraceAdj = [];
output.semHitEyelidTraceAdj = [];
output.meanMissEyelidTraceAdj = [];
output.semMissEyelidTraceAdj = [];
for m = 1:mousenum
    daylist = unique(data.date(data.mouse==m,1));
    
    crcrit = crcriteria(m);
    
    for d = 1:length(daylist)
        if d==1
            % this will be the day with the tone amplitude adjustments on
            % CS-only trials
            pairedTrials = find(data.mouse == m & data.date == daylist(d) & ...
               data.c_usdur>0 & data.type==1); % want to exclude the CS alone trials where the CS intensity can change
        else
            pairedTrials = find(data.mouse == m & data.date == daylist(d) & ...
                data.type==1);
        end
        
        baseline = nan(length(pairedTrials),1);
        stable = nan(length(pairedTrials),1);
        cradjamp = nan(length(pairedTrials),1);
        uramp = nan(length(pairedTrials),1);
        urampadj = nan(length(pairedTrials),1);
        astartleamp = nan(length(pairedTrials),1);
        urint = nan(length(pairedTrials),1);
        urintadj = nan(length(pairedTrials),1);
        eyelidposadj = nan(length(pairedTrials),200);
        for i = 1:length(pairedTrials)
            baseline(i,1) = data.baseline(pairedTrials(i), 1);
            cradjamp(i,1) = data.eyelidpos(pairedTrials(i), 76) - baseline(i,1);
            uramp(i,1) = max(data.eyelidpos(pairedTrials(i), 80:100)); % max FEC in the 100 ms after US triggered
            urampadj(i,1) = uramp(i,1)-baseline(i,1);
            urint(i,1) = trapz(timeVector(1,80:200), data.eyelidpos(pairedTrials(i), 80:200)); % area under the curve for the remainder of the trial after the US is triggered
            urintadj(i,1) = trapz(timeVector(1,80:200), data.eyelidpos(pairedTrials(i), 80:200)-baseline(i,1));
            stable(i,1) = data.baselineMvt(pairedTrials(i),1);
            eyelidposadj(i,1:200)=data.eyelidpos(pairedTrials(i),1:200)-baseline(i,1);
            astartleamp(i,1) = max(data.eyelidpos(pairedTrials(i), 40:50)) - baseline(i,1); % the max amplitude in the first 50 ms after the CS is presented
        end
        
        hitTrials = sum(cradjamp>crcrit & stable & baseline<0.3);
        totalTrials = sum(stable & baseline<0.3);
        output.CRProb(end+1,1) = hitTrials/totalTrials;
        
        output.mouse(end+1,1) = m;
        output.date(end+1,1) = daylist(d);
        
        output.meanCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3));
        output.hitCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3 & cradjamp>crcrit));
        output.missCRAdjAmp(end+1,1) = mean(cradjamp(stable & baseline<0.3 & cradjamp<=crcrit));
        
        output.meanAStartleAmp(end+1,1) = mean(astartleamp(stable & baseline<0.3));
        
        output.meanURAmp(end+1,1) = mean(uramp(stable & baseline<0.3));
        output.meanHitURAmp(end+1,1) = mean(uramp(stable & baseline<0.3 & cradjamp>=0.1));
        output.meanMissURAmp(end+1,1) = mean(uramp(stable & baseline<0.3 & cradjamp<0.1));
        output.meanURAmpAdj(end+1,1) = mean(urampadj(stable & baseline<0.3));
        output.meanHitURAmpAdj(end+1,1) = mean(urampadj(stable & baseline<0.3 & cradjamp>=0.1));
        output.meanMissURAmpAdj(end+1,1) = mean(urampadj(stable & baseline<0.3 & cradjamp<0.1));
        
        
        output.meanURIntegral(end+1,1)=mean(urint(stable & baseline<0.3));
        output.meanHitURIntegral(end+1,1)=mean(urint(stable & baseline<0.3 & cradjamp>=crcrit));
        output.meanMissURIntegral(end+1,1)=mean(urint(stable & baseline<0.3 & cradjamp<crcrit));
        output.meanURIntegralAdj(end+1,1)=mean(urintadj(stable & baseline<0.3));
        output.meanHitURIntegralAdj(end+1,1)=mean(urintadj(stable & baseline<0.3 & cradjamp>=crcrit));
        output.meanMissURIntegralAdj(end+1,1)=mean(urintadj(stable & baseline<0.3 & cradjamp<crcrit));
        
        % eyelid trace stuff
        output.meanEyelidTrace(end+1, 1:200) = mean(data.eyelidpos(pairedTrials,:));
        output.semEyelidTrace(end+1, 1:200) = std(data.eyelidpos(pairedTrials,:))/sqrt(length(pairedTrials));
        output.meanHitEyelidTrace(end+1, 1:200) = nan(1,200);
        output.semHitEyelidTrace(end+1, 1:200) = nan(1,200);
        output.meanMissEyelidTrace(end+1, 1:200) = nan(1,200);
        output.semMissEyelidTrace(end+1, 1:200) = nan(1,200);
        
        output.meanEyelidTraceAdj(end+1, 1:200) = mean(eyelidposadj);
        output.semEyelidTraceAdj(end+1, 1:200) = std(eyelidposadj)/sqrt(length(eyelidposadj));
        output.meanHitEyelidTraceAdj(end+1, 1:200) = nan(1,200);
        output.semHitEyelidTraceAdj(end+1, 1:200) = nan(1,200);
        output.meanMissEyelidTraceAdj(end+1, 1:200) = nan(1,200);
        output.semMissEyelidTraceAdj(end+1, 1:200) = nan(1,200);
        if hitTrials > 0
            output.meanHitEyelidTrace(end, 1:200) = mean(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :));
            output.semHitEyelidTrace(end, 1:200) = std(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :))/sqrt(length(pairedTrials));
            output.meanHitEyelidTraceAdj(end, 1:200) = mean(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :));
            output.semHitEyelidTraceAdj(end, 1:200) = std(eyelidposadj(cradjamp>crcrit & stable & baseline<0.3, :))/sqrt(length(pairedTrials));
        end
        if hitTrials < totalTrials
            output.meanMissEyelidTrace(end, 1:200) = mean(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3, :));
            output.semMissEyelidTrace(end, 1:200) = std(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3,:))/sqrt(length(eyelidposadj));
            output.meanMissEyelidTraceAdj(end, 1:200) = mean(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3,:));
            output.semMissEyelidTraceAdj(end, 1:200) = std(eyelidposadj(cradjamp<crcrit & stable & baseline<0.3,:))/sqrt(length(eyelidposadj));
        end
    end
end

end