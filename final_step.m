function final_step(Data,Param)

%% Calculate the coordinates of each vertex of the best spiral T-coil
Coord = singleended_ind(Data.geomParam(Data.best(end),:),Param);

%% Build SKILL Script for Modeling
Param.currentModel = strcat(Param.prjFolder,'/optimal_model');
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

% save model and output GDS file
fprintf(fid,'dbSave(CV)\n');
fprintf(fid,strcat('xstSetField("strmFile" "',Param.currentModel,'/out.gds")\n'));
fprintf(fid,strcat('xstSetField("layerMap" "',Param.pathMap,'")\n'));
fprintf(fid,'xstSetField("library" "myLib")\n');
fprintf(fid,'xstOutDoTranslate()\n');
fprintf(fid,'exit\n');
fclose(fid);
pause(2);

%% Call Virtuoso to Build Model
fprintf("Building Model with Virtuoso...\n");
for ii = 1:6
    if ii < 6 && exist(strcat(Param.currentModel,"/out.gds"),'file') == 0
        system(strcat("cd ",Param.currentModel," && virtuoso -nocdsinit -nograph -log cdslog",num2str(ii),".log -replay ",Param.pathScript,"&>/dev/null"));
    elseif exist(strcat(Param.currentModel,"/out.gds"),'file') ~= 0
        fprintf(strcat("The model is saved in ",Param.currentModel,", lib: myLib, cell: Inductor\n\n"));
        break;
    elseif ii == 6 && exist(strcat(Param.currentModel,"/out.gds"),'file') == 0
        error(strcat("Model generating failed! The folder is ",Param.currentModel));
    else
        pause(30);
    end
end

%% Plot and Save
plot_function(Data,Param,1);
Data.time = toc(Param.t);
fprintf("This synthesis took a total of %g h\n",Data.time/3600);
save(strcat(Param.prjFolder,'/data.mat'),"Data","Param");

end