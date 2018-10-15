function [hasCSpk, CSpkChangeDir, CSpkToEventProb, medianCSpkLatency,...
    hasSS, SSChangeDir, SSToEventRate, SSLat, SSDeviation] = ...
    gatherSpikeResponseMetrics(CSpk_times, SS_times, trialTimes,...
    eventTimes, ssBinSize, sortedPreTime, winOfInterest, makeFig)

        % check whether there is a CSpk response to the puff & save values
        [hasCSpk, outlyingnessCSpk, CSpkChangeDir, CSpkToEventProb, spikeProbs] = ...
            checkForResponse_chooseMetric(CSpk_times, trialTimes,...
            eventTimes, sortedPreTime, winOfInterest,...
            'probability', makeFig);
        if hasCSpk 
            % check the latency of the responses to the puff
            [cspklatsummary] = ...
                getLatencies_lowProbEvent(CSpk_times, eventTimes, eventTimes+0.1);
            medianCSpkLatency = cspklatsummary(1,2);            
        else
            medianCSpkLatency = NaN;
        end
        
             
        [hasSS, outlyingnessSS, SSChangeDir, SSToEventRate, resp] = ...
            checkForResponse_chooseMetric(SS_times,...
            trialTimes, eventTimes, sortedPreTime, winOfInterest, 'frequency', makeFig);
        if hasSS
            % check the latency of the responses to the puff, using the
            % same outlier analysis to detect at which bin the SS FR starts
            % increasing
            [SSLat, SSDeviation, medianabsdev, medianval, thisval] = ...
                getLatencies_fastEvent(SS_times, eventTimes, sortedPreTime,...
                winOfInterest, ssBinSize, SSChangeDir);
        else
            SSLat = NaN;
            SSDeviation = NaN;
            medianabsdev = NaN;
            medianval = NaN;
            thisval = NaN;
        end
end