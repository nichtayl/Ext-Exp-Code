function [hasResponse, realValOutlyingness, outlyingDir, thisdev, medabsdev, medianval] = ...
    isOutlier_MADMethod(vector)

% compute outlyingness
% see Leys et al., 2013 for description of this method
medianval = median(vector);
medabsdev = 1.4826 * median(abs(vector - medianval));
thisdev = (vector(1,end) - medianval);
realValOutlyingness = thisdev/medabsdev;
if abs(realValOutlyingness) >= 3
    hasResponse = 1;
else
    hasResponse = 0;
end

if realValOutlyingness>0
    outlyingDir = 1;
elseif realValOutlyingness<0
    outlyingDir = -1;
else
    outlyingDir = 0;
end

end