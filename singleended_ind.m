function Coord = singleended_ind(geomParam,Param)

%% Set Parameters
widthSpace = geomParam(2);% line space
widthLineMax = geomParam(1);% max line width
widthLineMin = geomParam(3);% min line width
widthInnerPoly = geomParam(5);% innermost polygon width
numTurns = geomParam(4);% turns
numDR = geomParam(6);% the deformation ratio

%% Calculate Innermost Polygon Parameters
if widthLineMax <= widthLineMin
    widthLineMax = widthLineMin + 0.001;
end
% width decrement
widthLineDelta = (widthLineMax-widthLineMin)/(numTurns*4);
% width of each segment
widthLine  = widthLineMin:widthLineDelta:widthLineMax;
widthLine = [widthLine widthLine(end)];
% polar coordinates of vertices of the innermost polygon
innerPolyPhy = -pi*3/4:pi/2:pi*3/4;
innerPolyR = ones(1,4).*((widthInnerPoly*numDR)/(0.956))/2;
[pointInnerPoly(:,1),pointInnerPoly(:,2)] = pol2cart(innerPolyPhy,innerPolyR);
% perform stretching or compression of the T-coil
pointInnerPoly(pointInnerPoly(:,1)>0,1) = pointInnerPoly(pointInnerPoly(:,1)>0,1) + 0.5*widthInnerPoly*(1-numDR);
pointInnerPoly(pointInnerPoly(:,1)<0,1) = pointInnerPoly(pointInnerPoly(:,1)<0,1) - 0.5*widthInnerPoly*(1-numDR);
% the unit direction vector of each edge of the innermost polygon, counterclockwise
vecUnit = [pointInnerPoly(2:end,:)-pointInnerPoly(1:end-1,:);pointInnerPoly(1,:)-pointInnerPoly(end,:)];
vecUnit = vecUnit./(sqrt(vecUnit(:,1).^2+vecUnit(:,2).^2));
% matrix rotated 90 degrees clockwise
matRot90 = [cos(-pi/2),sin(-pi/2);-sin(-pi/2),cos(-pi/2)];

%% Calculate Main Body Points of T-coil
% equation of each side of the initial polygon, k1*x+k2*y+k3 = 0
numK1 = [pointInnerPoly(2:end,2)-pointInnerPoly(1:end-1,2);pointInnerPoly(1,2)-pointInnerPoly(end,2)]';
numK2 = [pointInnerPoly(1:end-1,1)-pointInnerPoly(2:end,1);pointInnerPoly(end,1)-pointInnerPoly(1,1)]';
numK3 = [pointInnerPoly(2:end,1).*pointInnerPoly(1:end-1,2)-pointInnerPoly(1:end-1,1).*pointInnerPoly(2:end,2);...
    pointInnerPoly(1,1)*pointInnerPoly(end,2)-pointInnerPoly(end,1)*pointInnerPoly(1,2)]';
% inner circle vertex coordinates and outer circle vertex coordinates of the metal
xInner = [pointInnerPoly(1,1) zeros(1,numTurns*4)];
yInner = [pointInnerPoly(1,2) zeros(1,numTurns*4)];
xOuter = zeros(1,numTurns*4+1);
yOuter = zeros(1,numTurns*4+1);
% use linear translation and intersection to find the point of intersection
% the solution for the innermost metal is a little different from the other turns
for ii = 2:4
    % p1, p2, p3 represents the vertically unit direction vector
    vecP1 = (((widthLineMin+widthSpace)*(ii-1))/4).*(vecUnit(ii,:)*matRot90);
    vecP2 = widthLine(ii-1).*(vecUnit(ii-1,:)*matRot90);
    vecP3 = widthLine(ii).*(vecUnit(ii,:)*matRot90);
    % translate the line
    numK3(ii) = numK3(ii)-numK1(ii)*vecP1(1)-numK2(ii)*vecP1(2);
    numK4 = numK3(ii-1)-numK1(ii-1)*vecP2(1)-numK2(ii-1)*vecP2(2);
    numK5 = numK3(ii)-numK1(ii)*vecP3(1)-numK2(ii)*vecP3(2);
    % find the intersection of the current line with the previous line of the inner circle of metal
    solution1 = pinv([numK1(ii-1),numK2(ii-1);numK1(ii),numK2(ii)])*[-numK3(ii-1);-numK3(ii)];
    xInner(ii) = solution1(1);
    yInner(ii) = solution1(2);
    % find the intersection of the outer circle of metal
    solution2 = pinv([numK1(ii-1),numK2(ii-1);numK1(ii),numK2(ii)])*[-numK4;-numK5];
    xOuter(ii) = solution2(1);
    yOuter(ii) = solution2(2);
end
% solve for metals other than the first turn
for ii = 5:(4*numTurns+2)
    vecP1 = (widthLine(ii-4)+widthSpace).*(vecUnit(mod(ii-1,4)+1,:)*matRot90);
    vecP2 = widthLine(ii-1).*(vecUnit(mod(ii-2,4)+1,:)*matRot90);
    vecP3 = widthLine(ii).*(vecUnit(mod(ii-1,4)+1,:)*matRot90);
    numK3(mod(ii-1,4)+1) = numK3(mod(ii-1,4)+1)-...
        numK1(mod(ii-1,4)+1)*vecP1(1)-numK2(mod(ii-1,4)+1)*vecP1(2);
    numK4 = numK3(mod(ii-2,4)+1)-numK1(mod(ii-2,4)+1)*vecP2(1)-...
        numK2(mod(ii-2,4)+1)*vecP2(2);
    numK5 = numK3(mod(ii-1,4)+1)-numK1(mod(ii-1,4)+1)*vecP3(1)-...
        numK2(mod(ii-1,4)+1)*vecP3(2);
    
    solution1 = pinv([numK1(mod(ii-2,4)+1),numK2(mod(ii-2,4)+1);numK1(mod(ii-1,4)+1),numK2(mod(ii-1,4)+1)])*...
        [-numK3(mod(ii-2,4)+1);-numK3(mod(ii-1,4)+1)];
    xInner(ii) = solution1(1);
    yInner(ii) = solution1(2);
    
    solution2 = pinv([numK1(mod(ii-2,4)+1),numK2(mod(ii-2,4)+1);numK1(mod(ii-1,4)+1),numK2(mod(ii-1,4)+1)])*...
        [-numK4;-numK5];
    xOuter(ii) = solution2(1);
    yOuter(ii) = solution2(2);
end
% only half of the first metal regards as output
xInner(1) = (xInner(1)+xInner(2))/2;
yInner(1) = (yInner(1)+yInner(2))/2;
% only half of the last metal regards as input
xInner(end) = (xInner(end)+xInner(end-1))/2;
yInner(end) = (yInner(end)+yInner(end-1))/2;
% calculate the first and last points of the outer circle of the metal
vecP4 = vecUnit(1,:)*matRot90;
xOuter(1) = xInner(1)+widthLineMin*vecP4(1);
yOuter(1) = yInner(1)+widthLineMin*vecP4(2);
vecP4 = vecUnit(mod(numTurns*4,4)+1,:)*matRot90;
xOuter(end) = xInner(end)+widthLineMax*vecP4(1);
yOuter(end) = yInner(end)+widthLineMax*vecP4(2);

%% Calculate Input Port
% length and width of input port
lengthInput = widthLineMax+5;
widthInput = widthLineMax;
% input port coordinates
xInput = [xInner(end) xInner(end)+lengthInput*vecP4(1) ...
    xInner(end)+widthInput*vecUnit(mod(numTurns*4,4)+1,1)+lengthInput*vecP4(1)...
    xInner(end)+widthInput*vecUnit(mod(numTurns*4,4)+1,1)];
yInput = [yInner(end) yInner(end)+lengthInput*vecP4(2) ...
    yInner(end)+widthInput*vecUnit(mod(numTurns*4,4)+1,2)+lengthInput*vecP4(2)...
    yInner(end)+widthInput*vecUnit(mod(numTurns*4,4)+1,2)];

% width and length of output port
widthOutput = widthLineMin;
lengthOutput = widthLineMin+5;
% calculated separately based on whether the number of turns is an integer or not
vecP5 = -vecUnit(1,:)*matRot90;% the direction of output port
xOutput = [xOuter(1) xOuter(1)+widthOutput*vecUnit(1,1) xOuter(1)+widthOutput*vecUnit(1,1)+widthLineMin*vecP5(1) ...
    xOuter(1)+widthOutput*vecUnit(1,1)+lengthOutput*vecP5(1) xOuter(1)+lengthOutput*vecP5(1) xOuter(1)+widthLineMin*vecP5(1)];
yOutput = [yOuter(1) yOuter(1)+widthOutput*vecUnit(1,2) yOuter(1)+widthOutput*vecUnit(1,2)+widthLineMin*vecP5(2) ...
    yOuter(1)+widthOutput*vecUnit(1,2)+lengthOutput*vecP5(2) yOuter(1)+lengthOutput*vecP5(2) yOuter(1)+widthLineMin*vecP5(2)];

%% Coordinates Output
X.inner = xInner;
X.outer = xOuter;
X.input = xInput;
Y.inner = yInner;
Y.outer = yOuter;
Y.input = yInput;
X.output = xOutput;
Y.output = yOutput;
% each row of Coord.metal contains the complete information about the metal to be drawn
% Coord.metal{ii,:} = [{metal name},{x coordinates},{y coordinates}]
Coord.metal{1,1} = [Param.topMetal,"drawing"];Coord.metal{1,2} = [X.inner fliplr(X.outer)];Coord.metal{1,3} = [Y.inner fliplr(Y.outer)];
Coord.metal{2,1} = [Param.topMetal,"drawing"];Coord.metal{2,2} = X.input;Coord.metal{2,3} = Y.input;
Coord.metal{3,1} = [Param.bottomMetal,"drawing"];Coord.metal{3,2} = X.output([1,5,4,2]);Coord.metal{3,3} = Y.output([1,5,4,2]);

% each row of Coord.via contains the complete information about the area where to generate via
% Coord.via{ii,:} = [{x coordinates},{y coordinates}]
Coord.via{1,1} = [X.output(1:3) X.output(6)];Coord.via{1,2} = [Y.output(1:3) Y.output(6)];

% each row of Coord.pin contains the complete information about the pin to be drawn
% Coord.pin{ii,:} = [{metal name},{x coordinates},{y coordinates},{pin name}]
Coord.pin{1,1} = Param.topMetal;Coord.pin{1,2} = 0.5*(X.input(3)+X.input(2));Coord.pin{1,3} = 0.5*(Y.input(3)+Y.input(2));Coord.pin{1,4} = '1';
Coord.pin{2,1} = Param.bottomMetal;Coord.pin{2,2} = 0.5*(X.output(4)+X.output(5));Coord.pin{2,3} = 0.5*(Y.output(4)+Y.output(5));Coord.pin{2,4} = '2';

end