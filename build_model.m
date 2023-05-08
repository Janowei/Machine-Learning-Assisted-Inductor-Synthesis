function [Output,Param] = build_model(geomParam,Param)

%% Calculate Coordinates
Coord = singleended_ind(geomParam,Param);

%% Build SKILL Script
mkdir(Param.currentModel); % create model folder
copyfile(Param.pathCdslib,Param.currentModel); % copy cds.lib file to current model foder
Param.pathScript = strcat(Param.currentModel,'/CreateModel.txt');%create script file
fid = fopen(Param.pathScript,'wt');
fprintf(fid,strcat('LibID=dbCreateLib("myLib" "',Param.currentModel,'")\n'));%create Lib
fprintf(fid,strcat('techSetTechLibName(LibID "',Param.techLib,'")\n'));%attach to TechLib
fprintf(fid,'CV=dbOpenCellViewByType("myLib" "Inductor" "layout" "maskLayout" "w")\n');%create cell

% draw routing polygons
for ii = 1:size(Coord.metal,1)
    skillStr = strcat('dbCreatePolygon(CV list("',Coord.metal{ii,1}(1),'" "',Coord.metal{ii,1}(2),'") list(');
    for jj = 1:length(Coord.metal{ii,2})
        skillStr = strcat(skillStr,num2str(Coord.metal{ii,2}(jj)),':',num2str(Coord.metal{ii,3}(jj)),'\t');
    end
    skillStr = strcat(skillStr,'))\n');
    fprintf(fid,skillStr);
end

% draw vias
if isfield(Coord,'via')==1
    fprintf(fid,'TechID=techGetTechFile(CV)\n');
    fprintf(fid,'constraintGroupId = cstFindConstraintGroupIn(TechID "%s")\n',Param.constGroup);
    fprintf(fid,'viaOptions = viaGetViaOptions(constraintGroupId)\n');
    for ii = 1:size(Coord.via,1)
        fprintf(fid,strcat("viaGenerateViasInArea(CV list('(",num2str(Coord.via{ii,1}(1)),'\t', num2str(Coord.via{ii,2}(1)),')\t',...
            "'(",num2str(Coord.via{ii,1}(2)),'\t', num2str(Coord.via{ii,2}(2)),')\t',...
            "'(",num2str(Coord.via{ii,1}(3)),'\t', num2str(Coord.via{ii,2}(3)),')\t',...
            "'(",num2str(Coord.via{ii,1}(4)),'\t', num2str(Coord.via{ii,2}(4)),')) viaOptions)\n'));
    end
end

% draw pins
for ii = 1:size(Coord.pin,1)
    fprintf(fid,strcat('dbCreateLabel(CV "',Coord.pin{ii,1},'"\t',num2str(Coord.pin{ii,2}),':',...
        num2str(Coord.pin{ii,3}),'\t','"',Coord.pin{ii,4},'" "centerCenter" "R0" "roman" 1)\n'));
end

% save model and output GDS file
fprintf(fid,'dbSave(CV)\n');
fprintf(fid,strcat('xstSetField("strmFile" "',Param.currentModel,'/out.gds")\n'));
fprintf(fid,strcat('xstSetField("layerMap" "',Param.pathMap,'")\n'));
fprintf(fid,'xstSetField("library" "myLib")\n');
fprintf(fid,'xstOutDoTranslate()\n');
fprintf(fid,'exit\n');
fclose(fid);

%% Call Virtuoso to Build Model
fprintf("Building Model with Virtuoso...\n");
for ii = 1:6
    if ii < 6 && exist(strcat(Param.currentModel,"/out.gds"),'file') == 0
        system(strcat("cd ",Param.currentModel," && virtuoso -nocdsinit -nograph -log cdslog",num2str(ii),".log -replay ",Param.pathScript,"&>/dev/null"));
    elseif exist(strcat(Param.currentModel,"/out.gds"),'file') ~= 0
        fprintf(strcat("The model is saved in ",Param.currentModel,", lib: myLib, cell: Inductor\n"));
        break;
    elseif ii == 6 && exist(strcat(Param.currentModel,"/out.gds"),'file') == 0
        error(strcat("Model generating failed! The folder is ",Param.currentModel));
    else
        pause(30);
    end
end

%% Call EMX to Sovel Model
fprintf("Solving Model with EMX...\n");
[status,log] = system(strcat("cd ",Param.currentModel,";emx -e 1 --3d='*' -t 1 -v 1 ",Param.currentModel,...
        "/out.gds Inductor ",Param.pathProc," --sweep 1e8 ",num2str((Param.targetSRF+10)*1e9)," --log-file=emxlog.log",...
        " --sweep-num-steps=",num2str((Param.targetSRF+10)/0.1)," -p 'P1=1' -p 'P2=2' -i P1 -i P2 --parallel=8",...
        " -f touchstone --s-file=",Param.currentModel,"/sModel.s2p",...
        " -f touchstone --y-file=",Param.currentModel,"/yModel.y2p"));
if status==1
    fprintf("%s\n",log);
    error("Model solving failed,please check the model and log!");
else
    fprintf("Model solving succeed!\n");
end
pause(2);

%% Import Data
sModel = sparameters(strcat(Param.currentModel,'/sModel.s2p'));
yModel = yparameters(strcat(Param.currentModel,'/yModel.y2p'));
Output.freq = sModel.Frequencies(1:end)./1e9;% GHz
Output.modelS11 = reshape(sModel.Parameters(1,1,:),length(sModel.Parameters(1,1,:)),1);
Output.modelS21 = reshape(sModel.Parameters(2,1,:),length(sModel.Parameters(2,1,:)),1);
Output.modelS12 = reshape(sModel.Parameters(1,2,:),length(sModel.Parameters(1,2,:)),1);
Output.modelS22 = reshape(sModel.Parameters(2,2,:),length(sModel.Parameters(2,2,:)),1);
Output.modelY11 = reshape(yModel.Parameters(1,1,:),length(yModel.Parameters(1,1,:)),1);
Output.modelY21 = reshape(yModel.Parameters(2,1,:),length(yModel.Parameters(2,1,:)),1);
Output.modelY12 = reshape(yModel.Parameters(1,2,:),length(yModel.Parameters(1,2,:)),1);
Output.modelY22 = reshape(yModel.Parameters(2,2,:),length(yModel.Parameters(2,2,:)),1);
Output.geomParam = geomParam;
Output.L = imag((1./Output.modelY11)./(2*pi.*Output.freq));% nH
Output.Q = -imag(Output.modelY11)./real(Output.modelY11);
Area = calculate_area(geomParam);
Output.area = [Area.outerDiaWidth,Area.outerDiaHeight];

%% Curve Fitting
% the function used to fit the L curve
curveL = '-a*sin(pi/((x-b)+c/(x-b)))+d';

% if the resonance point is in the simulation band, the fitted initial point is the peak point
if isempty(Output.L(Output.L>(Output.L(1)+0.1))) == 0
    if isempty(findpeaks(Output.L,'MinPeakHeight',min(Output.L(1)+0.1))) == 0
        peaks = findpeaks(Output.L,'MinPeakHeight',min(Output.L(1)+0.1));
        startPoint = Output.freq(Output.L==peaks(1));
        % if not, the fitted initial point is larger than the simulation band
    else
        startPoint = Output.freq(end)+50;
    end
else
    startPoint = Output.freq(end)+50;
end
Option = fitoptions('Method','NonlinearLeastSquares',...
                              'Lower',[-100,startPoint/2,1,0],...
                              'Upper',[100,200,200,1],...
                              'StartPoint',[1 startPoint 1 0],...
                              'Normalize','off',...
                              'Robust','Bisquare',...
                              'MaxFunEvals',1000,...
                              'MaxIter',1000,...
                              'TolFun',1e-9,...
                              'Algorithm','Trust-Region');
FitL = fit(Output.freq,Output.L,curveL,Option);
if FitL.a>0 && FitL.a<1e-3
    FitL.a = 1e-3;
elseif FitL.a<0 && FitL.a>-1e-3
    FitL.a = -1e-3;
end
Output.coefL = [FitL.a,FitL.b,FitL.c,FitL.d];

[~,numQmax] = max(Output.Q);
num = find(Output.Q(numQmax:end)<0,1);
if isempty(num) == 1
    num = length(Output.freq);
end
minQ = min(Output.Q);
FitQ = fit(Output.freq(1:num),Output.Q(1:num)-minQ,'gauss1');
Output.coefQ = [FitQ.a1,FitQ.b1,FitQ.c1,minQ];

save(strcat(Param.currentModel,'/result.mat'),"Output");
fprintf("\n");
end