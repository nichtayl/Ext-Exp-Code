function twoScatter(tempacq, tempext, mouse, xlab, ylab, leglabs)
figure
scatter([1:length(tempacq)], tempacq)
hold on
scatter([length(tempacq)+1:length(tempacq)+length(tempext)], tempext)
ylabel(ylab)
xlabel(xlab)
legend(leglabs, 'location', 'NorthEast')
title(mouse)
end