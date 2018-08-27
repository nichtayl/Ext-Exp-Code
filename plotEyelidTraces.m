% assumes each row belongs to one animal and each column belongs to one day

% assumes that eyelidpos is a cell array with a mean trace of 1,200 size in
% each cell

% let groups be a 1 dimensional vector of length n including the rows of the animals to
% be included

% let daynums be an array of n rows by d columns, where d is the number of
% days to be included in the figure

function [plotMe] = plotEyelidTraces(eyelidpos, groups, daynums, timeVector,...
    legendLabels, titlestring, xlabelstring, ylabelstring, norm)

figure
hold on

[animals, days] = size(daynums);
plotMe = nan(days,200);
for d = 1:days
    averageMe = nan(animals,200);
    for a = 1:animals
        averageMe(a,1:200) = eyelidpos{groups(a),daynums(a,d)}(1,1:200);
        if norm == 1 % then plot data relative to baseline of the mean trace
            baseline = mean(averageMe(a,1:40));
            averageMe(a,1:200) = averageMe(a,1:200)-baseline;
        end
    end
    
    % mean returns a row vector containing the mean of each column as of
    % 180827
    plotMe(d,1:200) = mean(averageMe);
    
    clear averageMe
    
    plot(timeVector, plotMe(d,1:200))
end

legend(legendLabels, 'Location', 'NorthEast')

plot([0 0], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
plot([0.215 0.215], [0 1], 'LineStyle', ':', 'Color', [1 1 1])

title(titlestring)
xlabel(xlabelstring)
ylabel(ylabelstring)
end