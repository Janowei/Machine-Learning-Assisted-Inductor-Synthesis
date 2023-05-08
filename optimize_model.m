function  [Param,Data] = optimize_model(Param,Data)

%% Set the Maximum Number of Iterations
Param.numIter = 50;

%% Optimize Inductor Model
numOpt = 0;
% calculate the serial number of the target frequency point/band
[~,Param.numTarget(1)] = min(abs(Data.freq-Param.targetF)); %point of the working freq
[~,Param.numTarget(2)] = min(abs(Data.freq-Param.targetSRF)); %point of the SRF

while numOpt<Param.numIter
    numOpt = numOpt+1;
    fprintf('###################################\nTime:%d\n\n',numOpt);
    n = numOpt+Param.numSample;
    % LCb value
    lcb = [0 0.5 1 1.5 2];
    
    Param.currentModel = strcat(Param.prjFolder,'/',num2str(n));
    % if the project foder exists, remove it
    if exist(Param.currentModel,'dir') ~= 0
        rmdir(Param.currentModel,'s');
        pause(2);
    end
    
    % optimize model
    Output = ga_gpr_optimize(Param,Data,lcb(1:ceil((Param.numIter-numOpt+1)/10)));
    
    % restore data
    Data = restore_data(Output,Data,Param.numSample,n);
    
    % plot convergence progress
    plot_function(Data,Param,0);
    
    % determine if the terminating loop condition is met
    flag = satisfy_targets(Param,Data);
    % if satisfy the goals or 15 iterations no progress, break; the tolerace of L is 5%
    if flag == 1
        break;
    end
    pause(1);
end

end