% based on some spot checking, this algorithm is pretty good except for a
% few cases where the latency comes out as a negative number or very close
% to 0, this is a paucity of cases though and they can just be thrown out

% also currently only designed to work for animals with a tone CS

function [latency] = latencyIntersecOfSlopes(eyelidpos, tm, baseline)


y1 = eyelidpos(1,1);
y2 = eyelidpos(1,39);
x1 = tm(1,1);
x2 = tm(1,39);
baselineslope = (y2-y1)/(x2-x1);
baselineyintercept = y1 - (baselineslope * x1);
clear y1 y2 x1 x2

logicalArray = (eyelidpos(1,1:200) - baseline) > 0.1;
if sum(logicalArray(50:80))>0 % if there is a point >0.1 FEC higher than baseline
    tempidx = find(logicalArray);
    indices = tempidx(tempidx > 50 & tempidx < 80);
    if isempty(indices)
        latency = NaN;
        
    else
        movementslope = 0;
        pos = 0;
        while movementslope <= 0 && length(indices)>=pos+1
            % find the slope after the first point
            pos = pos+1;
            
            y2 = eyelidpos(1,indices(pos));
            y1 = eyelidpos(1, indices(pos)+1);
            x2 = tm(1,indices(pos));
            x1 = tm(1, indices(pos)+1);
            movementslope = (y2-y1)/(x2-x1);
            movementyintercept = y1 - (movementslope * x1);
            
            clear y2 y1 x2 x1
        end
        
        % find the intersection of the baselineslope and
        % the movementslope
        if movementslope<0 % to account for cases where indices was length 1 and the eye was opening at the time
            latency = NaN;
        else
            latency = (movementyintercept - baselineyintercept)/...
                (baselineslope - movementslope);
            
%             figure
%             plot(tm(1,1:200), eyelidpos(1,1:200))
%             b0=baselineyintercept; b1=baselineslope;
%             x= [-0.2:0.005:0.3]; % Adapt n for resolution of graph
%             y= b0+b1*x;
%             hold on
%             plot(x,y)
%             
%             b0=movementyintercept; b1=movementslope;
%             x= [-0.2:0.005:0.3]; % Adapt n for resolution of graph
%             y= b0+b1*x;
%             plot(x,y)
%             
%             xlim([-0.2 0.8])
%             ylim([-0.1 1.1])
        end
    end
else % if there is no point >0.1 FEC higher than baseline
    latency = NaN;
end


end