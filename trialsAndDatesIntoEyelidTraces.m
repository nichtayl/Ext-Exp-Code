function [eyelidpos] = trialsAndDatesIntoEyelidTraces(datespreadsheet_headers, datespreadsheet_dates, dayData, phase, adj)
[rows cols] = size(datespreadsheet_dates);
eyelidpos.mean = {};
eyelidpos.sem = {};
eyelidpos.hitmean = {};
eyelidpos.hitsem = {};
eyelidpos.missmean = {};
eyelidpos.hitsem = {};


% the different rows of the date spreadsheet specify the different days of
% each phase. that is, there is one row for the "during" phase of the
% manipulation for each animal, one row for the "after" phase, etc. each
% column corresponds to a different day of the phase specified in the row
% label in column 2 of the spreadsheet
idx = find(strcmpi(phase, datespreadsheet_headers(:,2)));
for i = 1:length(idx)
    r = idx(i);
    for c = 3:cols % start at col 3 because rows 1-2 is just headers
        thisDay = datespreadsheet_dates{r,c};
        thisMouse = datespreadsheet_dates{r,1};
        mouse = 0;
        %try
        % this if statement is here since I want to have different CR
        % criterion for OK138 since he had a big startle/SLR
        if ~ischar(thisDay) && ~isnan(thisDay) % skip days without numbers
            if strcmpi(thisMouse,'OK135')
                mouse=1;
            elseif strcmpi(thisMouse,'OK137')
                mouse=2;
            elseif strcmpi(thisMouse,'OK138')
                mouse=3;
            elseif strcmpi(thisMouse,'OK134')
                mouse=4;
            elseif strcmpi(thisMouse,'OK159')
                mouse=5;
            elseif strcmpi(thisMouse,'OK160')
                mouse=6;
            elseif strcmpi(thisMouse,'OK148')
                mouse=7;
            elseif strcmpi(thisMouse,'OK161')
                mouse=8;
            elseif strcmpi(thisMouse,'OK162')
                mouse=9;
            end
            if adj == 0
                eyelidpos.mean{mouse,c-2} = dayData.meanEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.sem{mouse,c-2} = dayData.semEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.hitmean{mouse,c-2} = dayData.meanHitEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.hitsem{mouse,c-2} = dayData.semHitEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.missmean{mouse,c-2} = dayData.meanMissEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.misssem{mouse,c-2} = dayData.semMissEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
            else
                eyelidpos.mean{mouse,c-2} = dayData.meanEyelidTraceAdj(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.sem{mouse,c-2} = dayData.semEyelidTraceAdj(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.hitmean{mouse,c-2} = dayData.meanHitEyelidTraceAdj(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.hitsem{mouse,c-2} = dayData.semHitEyelidTraceAdj(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.missmean{mouse,c-2} = dayData.meanMissEyelidTraceAdj(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
                eyelidpos.misssem{mouse,c-2} = dayData.semMissEyelidTraceAdj(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);

            end
            
            clear mouse thisDay thisMouse
        end
    end
end
end