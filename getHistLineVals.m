function [yvals, ymax, binvalues]=getHistLineVals(yaxistype, differences, triggers,...
    binedges, bindur, events)

if strcmpi(yaxistype, 'frequency')
    counts = zeros(length(binedges)-1, 1);
    for i = 1:length(binedges)-1
        temp = differences>=binedges(i) & differences<binedges(i+1);
        counts(i,1) = sum(temp);
    end
    
    binvalues = counts/(bindur*length(triggers));
    ymax = max(counts/(bindur*length(triggers)))*1.1;
elseif strcmpi(yaxistype, 'probability')
    % to get probability
    % for each trigger, compute the times at the binedges
    % then, check whether a spike occurs within each pair of binedges
    % then, populate a logical array with length(triggers) rows and
    %       length(binedges)-1 columns
    % then, sum columns and divide by number of trials to get probability
    
    spikeoccd = zeros(length(triggers), length(binedges)-1);
    for t = 1:length(triggers)
        binedgetimes = triggers(t,1) + binedges;
        for b = 1:length(binedgetimes)-1
            if sum(events>binedgetimes(b) & events<=binedgetimes(b+1))>0
                spikeoccd(t,b) = 1;
            end
        end
    end
    binsums = sum(spikeoccd,1);
    binvalues = binsums/length(triggers);
    
    ymax = 1;
end

yvals = [];
for i = 1:length(binvalues)
    yvals = [yvals, binvalues(i), binvalues(i)];
end

end