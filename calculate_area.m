% this function is used to calculate the area of the inductor
function Area = calculate_area(geomParam)

widthSpace = geomParam(:,2);% line space
widthLineMax = geomParam(:,1);% max line width
widthLineMin = geomParam(:,3);% min line width
widthInnerPoly = geomParam(:,5);% innermost polygon width
numTurns = geomParam(:,4);% turns
numDR = geomParam(:,6);% the deformation ratio
widthLineMax(widthLineMax<=widthLineMin,:) = widthLineMin(widthLineMax<=widthLineMin,:)+0.001;

widthLineDelta = (widthLineMax-widthLineMin)./(numTurns.*4);
innerDiaHeight = numDR.*widthInnerPoly + (widthLineMin+widthSpace).*0.5;
innerDiaWidth = widthInnerPoly + widthLineMin + widthSpace;
for ii = 1:length(widthLineDelta)
    widthLine  = widthLineMin(ii):widthLineDelta(ii):widthLineMax(ii);
    outerDiaHeight(ii,:) = innerDiaHeight(ii) + sum(widthLine(1:2:end)) + (length(widthLine(1:2:end))-2)*widthSpace(ii);
    outerDiaWidth(ii,:) = innerDiaWidth(ii) + sum(widthLine(2:2:end)) + (length(widthLine(2:2:end))-2)*widthSpace(ii);
end

Area.innerDiaHeight = innerDiaHeight;
Area.innerDiaWidth = innerDiaWidth;
Area.outerDiaHeight = outerDiaHeight;
Area.outerDiaWidth = outerDiaWidth;
Area.area = outerDiaHeight.*outerDiaWidth;
end