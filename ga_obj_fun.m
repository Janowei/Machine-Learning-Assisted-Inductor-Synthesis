% this function is the objective function of the GA optimization
function sumError = ga_obj_fun(geomParam, Param, freq, lcb, modQ, modL)

%% Predicting L and Q
for ii = 1:size(modL,2)
    [preCoefL(ii),sCoefL(ii)] = predict(modL{ii},geomParam);
end
% use UCB approach
temp = preCoefL(3);
temp(temp<1) = 1;
preCoefL(3) = temp;
preL = -preCoefL(1).*sin(pi./((freq-preCoefL(2))+preCoefL(3)./(freq-preCoefL(2))))+preCoefL(4);

for ii = 1:size(modQ,2)
    [preCoefQ(ii),sCoefQ(ii)] = predict(modQ{ii},geomParam);
end
% use UCB approach
preCoefQ(1) = preCoefQ(1) + lcb.*sCoefQ(1);
preCoefQ(3) = preCoefQ(3) + lcb.*sCoefQ(3);
preQ = preCoefQ(1).*sin((freq.^preCoefQ(2)).*(pi/(preCoefQ(3).^preCoefQ(2))));
n = find(preQ<0,1);
if isempty(n)==0
    m = find(preQ(n:end)>0,1);
    if isempty(m)==0
        [minQ,position] = min(preQ(n:n+m-2));
        preQ(n+position-1:end) = minQ;
    end
end

%% Returning Adaptations Based on Set Targets
% the maximum Q, L at the target frequency and SRF are of interest
% penalty is given when the targets of L and SRF are not satisfied
if preQ(Param.numTarget(2))<0.5 || abs(preL(Param.numTarget(1))-Param.targetL)/Param.targetL>0.01
    error1 = -preQ(Param.numTarget(2))+0.5;
    error2 = abs(preL(Param.numTarget(1))-Param.targetL)/(0.01*Param.targetL);
    sumError = 2^(max([error1 error2]));
    return;
    % maximizing Q
else
    sumError = -preQ(Param.numTarget(1));
    return;
end
   
end