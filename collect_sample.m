function [Param, Data] = collect_sample(Param)

%% Set the Initial Sample Size
Param.numSample = 60;

%% Sample with the Expanded Wheeler Formula
% random generation of large combinations of geometric parameters
matRandom = lhsdesign(100000,6);
matX(:,1) = Param.lineWidth(2)+(Param.lineWidth(1)-Param.lineWidth(2)).*matRandom(:,1); %max line width
matX(:,2) = Param.lineSpace(2)+(Param.lineSpace(1)-Param.lineSpace(2)).*matRandom(:,2); %line space
matX(:,3) = Param.lineWidth(2)+(matX(:,1)-Param.lineWidth(2)).*matRandom(:,3); %min line width
matX(:,4) = Param.coilTurn(2)+(Param.coilTurn(1)-Param.coilTurn(2)).*matRandom(:,4); %coil turns
matX(:,5) = 10+(Param.maxArea(1)-10).*matRandom(:,5); %Din width
matX(:,6) = Param.deformRatio(2)+(Param.deformRatio(1)-Param.deformRatio(2))*matRandom(:,6); %deformation ratio
matX(:,4) = round(matX(:,4));

% calculate the size of the inductor
Area = calculate_area(matX);
innerDiaWidth = Area.innerDiaWidth;
innerDiaHeight = Area.innerDiaHeight;
outerDiaHeight = Area.outerDiaHeight;
outerDiaWidth = Area.outerDiaWidth;
minDiaWidth = 10; % the minimum innermost polygon width

% calculating DC inductance values using the Extended Wheeler Formula
averageDia = sqrt((outerDiaHeight+innerDiaHeight).*(outerDiaWidth+innerDiaWidth))./2.*1e-6;
rho = (sqrt(outerDiaWidth.*outerDiaHeight)-sqrt(innerDiaHeight.*innerDiaWidth))./...
    (sqrt(outerDiaWidth.*outerDiaHeight)+sqrt(innerDiaHeight.*innerDiaWidth));
Ldc = ((2.34*4*pi*(1e-7).*matX(:,4).^2.*averageDia)./(1+3.99.*rho))*1e9;

% from all the geometric parameters filtered to meet the requirements
% it is required that the selected geometric parameters satisfy constraints on area, line width, etc. 
% it also needs to satisfy the Extended Wheeler Formula, the DC inductance tolerance is 30%
% this part cannot generate more than half of the total sample
geomParam1 = matX((abs(Ldc-Param.targetL)./Param.targetL)<=0.3&outerDiaWidth+0.5<Param.maxArea(1)&...
    outerDiaHeight+0.5<Param.maxArea(2)&matX(:,1)>matX(:,3)&matX(:,5)>minDiaWidth,:);
if size(geomParam1,1) >= 40
    geomParam1 = geomParam1(1:40,:);
end

if isempty(geomParam1) == 1
    error("Please increase the area or reduce the inductance value!");
end

%% Rondom Sampling
% random generation of large combinations of geometric parameters
matRandom = lhsdesign(100000,6);
matX(:,1) = Param.lineWidth(2)+(Param.lineWidth(1)-Param.lineWidth(2)).*matRandom(:,1); %max line width
matX(:,2) = Param.lineSpace(2)+(Param.lineSpace(1)-Param.lineSpace(2)).*matRandom(:,2); %line space
matX(:,3) = Param.lineWidth(2)+(matX(:,1)-Param.lineWidth(2)).*matRandom(:,3); %min line width
matX(:,4) = Param.coilTurn(2)+(Param.coilTurn(1)-Param.coilTurn(2)).*matRandom(:,4); %coil turns
matX(:,5) = 10+(Param.maxArea(1)-10).*matRandom(:,5); %Din width
matX(:,6) = Param.deformRatio(2)+(Param.deformRatio(1)-Param.deformRatio(2))*matRandom(:,6); %deformation ratio
matX(:,4) = round(matX(:,4));

% calculate the size of the inductor
Area = calculate_area(matX);
outerDiaHeight = Area.outerDiaHeight;
outerDiaWidth = Area.outerDiaWidth;

% from all the geometric parameters filtered to meet the requirements
geomParam2 = matX(outerDiaWidth+0.5<Param.maxArea(1)&outerDiaHeight+0.5<Param.maxArea(2)&...
    matX(:,5)>minDiaWidth&matX(:,1)>matX(:,3),:);

if isempty(geomParam2) == 1
    error("Please increase the area!");
end

%% Call Virtuoso and EMX to Model and Simulate Samples
Data.geomParam = [geomParam2(1:Param.numSample-size(geomParam1,1),:);geomParam1];

fprintf("###################################\nCollecting initial samples...\n\n");
for ii = 1:size(Data.geomParam,1)
    fprintf(strcat(num2str(ii-1)," samples collected, ",num2str(Param.numSample-ii+1)," samples left\n"));
    Param.currentModel = strcat(Param.prjFolder,'/',num2str(ii));
    % if the model is already exists and simulated, reload data
    if exist(Param.currentModel,'dir') ~= 0
        if exist(strcat(Param.currentModel,'/result.mat'),'file') == 0
            rmdir(Param.currentModel,'s');
            pause(2);
            [Output,Param] = build_model(Data.geomParam(ii,:),Param);
        else
            load(strcat(Param.currentModel,'/result.mat'));
        end
        % if not, build model
    else
        [Output,Param] = build_model(Data.geomParam(ii,:),Param);
    end
    % restore data
    Data = restore_data(Output,Data,Param.numSample,ii);
end

end