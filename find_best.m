% this function is used to find the best samples under various objectives
% the self-resonant frequency is judged by whether the Q value is greater than 0
function [bestSample,error] = find_best(L,Q,Param)

%% Electrical Parameters at the Target Points
simL = L(Param.numTarget(1),:)';
simQ = Q(Param.numTarget(1),:)';
simQSRF = Q(Param.numTarget(2),:)';

%% Calculate the Relative Error of Each Sample to the Targets
% use normalized Q as a criterion when maximizing Q
errorQ = -simQ./max(simQ);
% L error at center/target frequency
errorL = abs(simL-Param.targetL)./Param.targetL;
% Use whether Q is greater than 0 at SRF as the basis for whether SRF target is satisfied
errorSRF = -simQSRF;
% preventing excessive Q from influencing judging
errorSRF(errorSRF<-0.05) = -0.05;

%% Find the Best Sample Under Each Target
[~,bestQ] = min(errorQ);
[~,bestL] = min(errorL);
[~,bestSRF] = min(errorSRF);

%% Pick the Return Value Based on the Setting Targets
% the normalized maximum Q, L at the target frequency and SRF are of interest
error = [errorQ errorL errorSRF];
% if there are samples that satisfiy the L and SRF targets, return the one with the largest Q
if isempty(errorQ(errorL<0.05 & errorSRF<0)) == 0
    position = find(errorL<0.05 & errorSRF<0);
    [~,maxQ] = min(errorQ(errorL<0.05 & errorSRF<0));
    [~,minQ] = max(errorQ(errorL<0.05 & errorSRF<0));
    bestSample = [position(maxQ),bestQ,bestL,bestSRF,position(minQ)];
    error = error(bestSample(1),:);
    % otherwise return the one with the smallest sum error
else
    [~,rank] = sort(sum(error(:,2:3),2));
    bestSample = [rank(1),bestQ,bestL,bestSRF,rank(ceil(length(rank)/2))];
    error = error(rank(1),:);
end

end