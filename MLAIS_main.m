% This is a machine learning-assisted inductor synthesis (MLAIS) demo program. 
% The current version is 1.0.
function MLAIS_main()
    clc;
    clear;
    close all;
    warning off;
    Param.t = tic;
    
    %% Step 1: Set targets
    % 1.1 Set the inductance value in nH
    Param.targetL       = 0.3;
    % 1.2 Set operating frequency or center frequency in GHz
    Param.targetF       = 50;
    % 1.3 Set self-resonant frequency in GHz
    Param.targetSRF     = 80;
    
    %% Step 2: Set constrains
    % 2.1 Set maximum area, e.g. 60*30 or 30*60 -> [60 30] in um*um
    Param.maxArea       = [200 200];
    % 2.2 Set the range of line width in um
    Param.lineWidth     = [20 1];
    % 2.3 Set the range of line space in um
    Param.lineSpace     = [3 0.1];
    % 2.4 Set the range of coil turns which should be integer
    Param.coilTurn      = [5 1];
    
    %% Step3: Set process parameters
    % make sure your inputs are SAME as Cadence Virtuoso
    % 3.1 Set process name
    Param.techLib       = "Process Name";
    % 3.2 Set metal layers
    Param.topMetal      = "Metal 1 Name";
    Param.bottomMetal   = "Metal 2 Name";
    % 3.3 Input cds.lib, the specified process must be included in this file
    Param.pathCdslib    = "CDS.LIB Path";
    % 3.4 Constrains group name, usually listed in the process techfile
    Param.constGroup    = "virtuosoDefaultSetup";
    % 3.5 Input the path to the process file used for the EMX simulation
    Param.pathProc      = "PROC Path";
    % 3.6 Input the path of the process layermap file
    Param.pathMap       = "Layermap Path";
    
    %% Step 4: Initialize the Project
    Param               = init_project(Param);
    
    %% Step 5: Collect initial samples
    [Param, Data]       = collect_sample(Param);
    
    %% Step 6: Optimize
    [Param, Data]       = optimize_model(Param, Data);
    
    %% Step 7: Output the best sample
    final_step(Data, Param);
return;