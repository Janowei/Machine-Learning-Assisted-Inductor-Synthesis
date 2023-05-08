function Output = ga_gpr_optimize(Param,Data,lcb)

%% Setting Parameters
geomParam = Data.geomParam;
freq = Data.freq;
L = Data.L;
Q = Data.Q;
coefL = Data.coefL;
coefQ = Data.coefQ;

%% Find the Best Sample Among All Samples Under the Current Target
% the best sample found is used as the starting point of the GA to speed up the iteration
best = find_best(L,Q,Param);

%% Training Surrogate Model
fprintf('Training data...\n');
% training the agent model for each coefficient
for ii = 1:size(coefL,2)
    modL{ii} = fitrgp(geomParam(:,1:6),coefL(:,ii),'KernelFunction','ardmatern52','BasisFunction','none','Standardize',1,'PredictMethod','exact');
end
for ii = 1:size(coefQ,2)
    modQ{ii} = fitrgp(geomParam(:,1:6),coefQ(:,ii),'KernelFunction','ardmatern52','BasisFunction','none','Standardize',1,'PredictMethod','exact');
end
fprintf('Training completed!\n\n');
    
%% GA Optimize
% there are different objective functions for different lcb
for ii = 1:length(lcb)
    gaObjFun{ii} = @(geomParam)ga_obj_fun(geomParam,Param,freq,lcb(ii),modQ,modL);
end

% linear inequality constraint, Wmax>Wmin
aIn = [-1 0 1 0 0 0];
bIn = 0;

lB = [Param.lineWidth(2) Param.lineSpace(2) Param.lineWidth(2) Param.coilTurn(2) 10 Param.deformRatio(2)];
uB = [Param.lineWidth(1) Param.lineSpace(1) Param.lineWidth(1) Param.coilTurn(1) Param.maxArea(1) Param.deformRatio(1)];

% options for GA optimization
gaOptions = optimoptions(@ga,...
    'MaxGenerations',500,...
    'EliteCount',10,...
    'UseVectorized', false,...
    'InitialPopulationMatrix',geomParam(best,1:6),...
    'PopulationSize',200);
rng default

% GA optimization
fprintf('Global optimizing...\n');
for ii = 1:length(lcb)
    [optParam(ii,:),val(ii)] = ga(gaObjFun{ii},length(lB),aIn,bIn,[],[],lB,uB,...
        @(geomParam)ga_nonlinear_constrains(geomParam,Param),4,gaOptions);
    fprintf('The best function value found was : %g\n', min(val(ii)));
end
fprintf('\n');

%% Predict, Verify and Calculate Error
% full-wave simulation verification of each optimal point
for ii = 1:length(lcb)
    pathCurrentModel = Param.currentModel;
    Param.currentModel = strcat(Param.currentModel,'/',num2str(ii));
    [Result,~] = build_model(optParam(ii,:),Param);
    Output.modelS11(:,ii) = Result.modelS11;% complex
    Output.modelS21(:,ii) = Result.modelS21;
    Output.modelS12(:,ii) = Result.modelS12;
    Output.modelS22(:,ii) = Result.modelS22;
    Output.modelY11(:,ii) = Result.modelY11;% complex
    Output.modelY21(:,ii) = Result.modelY21;
    Output.modelY12(:,ii) = Result.modelY12;
    Output.modelY22(:,ii) = Result.modelY22;
    Output.geomParam(ii,:) = Result.geomParam;
    Output.L(:,ii) = Result.L;
    Output.Q(:,ii) = Result.Q;
    Output.coefL(ii,:) = Result.coefL;
    Output.coefQ(ii,:) = Result.coefQ;
    Output.area(ii,:) = Result.area;
    Param.currentModel = pathCurrentModel;
end

% find the best one in the current iteration
best = find_best(Output.L,Output.Q,Param);
Output.iterBest = best(1);
geomParam = optParam(Output.iterBest,:);

% find the best one among all samples
[best,error] = find_best([L Output.L],[Q Output.Q],Param);
% record the serial number of the optimal sample
Output.best = best(1);
% output error of the optimal sample
Output.minError = error;

% calculate the predicted L and Q of the best sample in this iteration
for ii = 1:size(modL,2)
    preCoefL(ii) = predict(modL{ii},geomParam);
end
temp = preCoefL(3);
temp(temp<1) = 1;
preCoefL(3) = temp;
Output.preL = -preCoefL(1).*sin(pi./((freq-preCoefL(2))+preCoefL(3)./(freq-preCoefL(2))))+preCoefL(4);
for ii = 1:size(modQ,2)
    preCoefQ(ii) = predict(modQ{ii},geomParam);
end
Output.preQ = preCoefQ(1).*sin((freq.^preCoefQ(2)).*(pi/(preCoefQ(3).^preCoefQ(2))));
n = find(Output.preQ<0,1);
if isempty(n)==0
    m = find(Output.preQ(n:end)>0,1);
    if isempty(m)==0
        [minQ,position] = min(Output.preQ(n:n+m-2));
        Output.preQ(n+position-1:end) = minQ;
    end
end

% calculate error of the prediction
Output.preError(1) = Output.preL(Param.numTarget(1))-Output.L(Param.numTarget(1),Output.iterBest);
Output.preError(2) = Output.preQ(Param.numTarget(1))-Output.Q(Param.numTarget(1),Output.iterBest);
Output.preError(3) = Output.preQ(Param.numTarget(2))-Output.Q(Param.numTarget(2),Output.iterBest);
fprintf('PreL Error:%gnH, PreQ Error:%g, PreQself Error:%g\n\n', Output.preError);
pause(2);
end