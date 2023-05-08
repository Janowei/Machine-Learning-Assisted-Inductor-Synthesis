% this function is used to determine if the loop termination condition is met
function flag=satisfy_targets(Param,Data)

L = Data.L(Param.numTarget(1),Data.best(end));
Q = Data.Q(Param.numTarget(2),Data.best(end));

% determine if no progress has been made in 15 consecutive iterations
noProgress = 0;
if length(Data.best) > 15
    if Data.best(end-7:end)==Data.best(end-14:end-7)
        noProgress = 1;
    end
end

% if you need to maximize Q, 
% the loop is terminated when the error between L and the target is less than 5%
% and the target of SRF is satisfied, and noProgress effective
if abs(L-Param.targetL)/Param.targetL<0.05 && Q>0 && noProgress==1
    flag = 1;
    return
else
    flag = 0;
    return
end

end