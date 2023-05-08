function Param = init_project(Param)

%% Confirm System Type
if isunix == 0
    error("The program can only be run on Linux platforms!");
end
    
%% Check the Input Value
if Param.maxArea(2)>Param.maxArea(1)
    error("The longer side is in front when inputing the maximum area!");
end
if Param.lineWidth(2)>Param.lineWidth(1)
    error("Max line width should be larger than min line width!");
end
if Param.lineSpace(2)>Param.lineSpace(1)
    error("Max line space should be larger than min line space!");
end
if Param.coilTurn(2)>Param.coilTurn(1)
    error("Max coil turns should be larger than min coil turns!");
end
if exist(Param.pathProc,'file') == 0
    error("The process file does not exist!");
end
if exist(Param.pathCdslib,'file') == 0
    error("The cds.lib file does not exist!");
end
if exist(Param.pathMap,'file') == 0
    error("The layermap file does not exist!");
end

%%  Create Project Foder
% get current path
tempPath = mfilename('fullpath');
ii = strfind(tempPath,'/');
Param.currentFolder = tempPath(1:ii(end)-1);
% create a working directory
Param.workingFolder = strcat(Param.currentFolder,'/Project');
if exist(Param.workingFolder,'dir') == 0
    mkdir(Param.workingFolder);
end
% create a project directory
Param.prjFolder = strcat(Param.workingFolder,'/',num2str(Param.targetL),'n_',num2str(Param.targetF),'G_',...
    num2str(Param.targetSRF),'G_',Param.techLib,'_',Param.topMetal,'_',Param.bottomMetal);
if exist(Param.prjFolder,'dir') == 0
    mkdir(Param.prjFolder);
end
% deformation ratio
Param.deformRatio = [1 0.1];
end