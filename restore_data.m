% this function is used to store data
function Data = restore_data(Output,Data,numSample,ii)

jj = size(Output.geomParam,1);

% the initial sample will only have one set of sample data per round
if ii <= numSample
    Data.freq = Output.freq;% GHz
    Data.geomParam(ii,:) = Output.geomParam;
    Data.modelS11(:,ii) = Output.modelS11;% complex
    Data.modelS21(:,ii) = Output.modelS21;
    Data.modelS12(:,ii) = Output.modelS12;
    Data.modelS22(:,ii) = Output.modelS22;
    Data.modelY11(:,ii) = Output.modelY11;% complex
    Data.modelY21(:,ii) = Output.modelY21;
    Data.modelY12(:,ii) = Output.modelY12;
    Data.modelY22(:,ii) = Output.modelY22;
    Data.L(:,ii) = Output.L;
    Data.Q(:,ii) = Output.Q;
    Data.coefL(ii,:) = Output.coefL;
    Data.coefQ(ii,:) = Output.coefQ;
    Data.area(ii,:) = Output.area;
% the number of samples returned during optimization changes with the number of LCB values
else
    Data.iterBest(ii,:) = [size(Data.geomParam,1) + Output.iterBest Output.iterBest];
    Data.geomParam(end+1:end+jj,:) = Output.geomParam;
    Data.modelS11(:,end+1:end+jj) = Output.modelS11;% complex
    Data.modelS21(:,end+1:end+jj) = Output.modelS21;
    Data.modelS12(:,end+1:end+jj) = Output.modelS12;
    Data.modelS22(:,end+1:end+jj) = Output.modelS22;
    Data.modelY11(:,end+1:end+jj) = Output.modelY11;% complex
    Data.modelY21(:,end+1:end+jj) = Output.modelY21;
    Data.modelY12(:,end+1:end+jj) = Output.modelY12;
    Data.modelY22(:,end+1:end+jj) = Output.modelY22;
    Data.L(:,end+1:end+jj) = Output.L;
    Data.Q(:,end+1:end+jj) = Output.Q;
    Data.coefL(end+1:end+jj,:) = Output.coefL;
    Data.coefQ(end+1:end+jj,:) = Output.coefQ;
    Data.area(end+1:end+jj,:) = Output.area;
end

if isfield(Output,'preL') == 1
    Data.preL(:,ii) = Output.preL;
    Data.preQ(:,ii) = Output.preQ;
    Data.preError(ii,:) = Output.preError;
    Data.minError(ii,:) = Output.minError;
    Data.best(ii) = Output.best;
end
end