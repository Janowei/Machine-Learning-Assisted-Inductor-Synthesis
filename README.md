# Machine-Learning-Assisted-Inductor-Synthesis
This machine learning-assisted inductor synthesis (MLAIS) demo program is used for efficient on-chip spiral inductor automatic synthesis.

This machine learning-assisted inductor synthesis (MLAIS) demo program contains a total of 15 functions.
1. MLAIS_main: Main function, set the targets, process and other parameters here.
2. build_model: This function will call Cadence Virtuoso and EMX for simulation to obtain the performance of inductors.
3. calculate_area: This function will calculate the area and other information based on the geometric parameters of inductors.
4. collect_sample: This function generates the initial sample set based on the targets and constraints.
5. final_step: Output optimal layout. 
6. find_best: Find the optimal one among all samples. 
7. ga_gpr_optimize: Global optimize using GA and GPR. 
8. ga_nonlinear_constrains: Nonlinear constrains for GA. 
9. ga_obj_fun: Objective function of GA. 
10. init_project: Check inputs and initialize the project. 
11. optimize_model: Multi-branch optimization. 
12. plot_function: This function draws iterative information. 
13. restore_data: Store the data of each sample and iteration.
14. satisfy_targets: Determine if the stop condition is met. 
15. singleended_ind: Calculate the coordinates of each point based on the geometric parameters of the inductor. 

The execution of this demo program contains the following 7 steps: 
1. Set targets: The user needs to set the inductance value, operating frequency, and minimum self-resonant frequency of the desired inductor, and the program will search the inductor of maximum quality factor that meets these conditions.
2. Set constraints: The user needs to set the geometric constraints of the spiral inductor, including area, wire width, wire spacing, and number of turns.
3. Set process parameters: The user needs to set the IC process, and declare the process name, the metal layer name, and the constraint group name. Please make sure that the above names are consistent with the names in Cadence VIRTUOSO. In addition, the path of CDS.LIB needs to be entered. The CDS.LIB file contains the process PDK path. The proc file for EMX simulation, and the layermap file corresponding to the process are also needed.
4. Initialize the project: Checks the user input for errors and creates the project directory.
5. Collect initial samples: Collects a certain number of samples according to the targets.
6. Optimize model: Multibranch machine learning-assisted optimization (MB-MLAO) is performed.
7. Output the best sample: The best sample will be automatically outputted to the specified directory. 

This program is supported to run under Linux platform only. Recommended Linux distributions include but are not limited to RHEL6 (6.5+), RHEL7 (7.4+), SLES11, SLES12, CentOS6 (6.5+), and CentOS7 (7.4+), see Cadence Virtuoso supported Linux distributions. 

Three softwares that this demo program depends on are as follows:
1. Cadence Virtuoso: Required version is 6.18, and please add the <VirtuosoPath>/bin directory to the environment variable. Make sure that input "virtuoso -V" in the terminal will output the version information correctly. 
2. EMX: Required version is 5.x. Please add <EMXPath> to the environment variable. Make sure that input "emx --version" in the terminal will output the version information correctly. 
3. Matlab: Required version is 2018b and above. 2018b is recommended.

please cite: 
J. Wei et al., "Highly Efficient Automatic Synthesis of a Millimeter-Wave On-Chip Deformable Spiral Inductor Using a Hybrid Knowledge-Guided and Data-Driven Technique," in IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems, doi: 10.1109/TCAD.2023.3294449.
