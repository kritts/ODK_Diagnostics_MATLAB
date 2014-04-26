% Given data for an intensity curve of a test
% determines slope of curve at the given index and area below the given 
% value
function [slopeUp, slopeDown, areaUnderCurve] = getSlopeAndArea(normalizedValues, indexUp, minValue)
    if(~isempty(indexUp))
        slopeUp = (normalizedValues(indexUp + 5) - normalizedValues(indexUp))/5;
        allValuesDown = find(normalizedValues > minValue);
        listDownwards = find(allValuesDown > indexUp,1);
        indexDown = allValuesDown(listDownwards);
        slopeDown = (normalizedValues(indexDown) - normalizedValues(indexDown - 5))/5;
        areaUnderCurve = sum(normalizedValues(indexUp:indexDown));
    else
        slopeUp = 0;
        slopeDown = 0;
        areaUnderCurve = 0;

    end
end 