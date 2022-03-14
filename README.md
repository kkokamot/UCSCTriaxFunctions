# UCSC Triax Functions

These functions are used in analyzing friction data from the UCSC triaxial deformation apparatus in matlab.  

The function **readUCSCtriax** reads in autolab data as a matlab table (ignores headerlines). 

**displacement_correction** function calculates area change during shear.  

**area_correction_ucsc** calculates shear stress during the experiment by calculating the shear force and then dividing by the sample area. This returns both shear stress without the displacement corrected area and with the displacement corrected area.

**calc_mu_UCSC** uses both the displacement correction and area correction functions to calculate friction (mu). It plots displacement corrected friction as well as non displacement corrected friction. It also plots the area correction and the displacement correction to LVDT3 (compaction). It saves these figures as well as the final experiment table.  The final experiment table is the initial experiment table with added columns for shear, shear_dc (displacement corrected), comp (LVDT3 displacement corrected), friction, friction_dc (displacement corrected), and friction as calculated from the axial control pressure.

**find_holds** creates a mat file of all the hold locations.

**find_k_holds** uses the mat file from find_holds to find the stiffness of each hold as well as delta_mu, delta_mu_c for various steady state possibilities.

**plot_overlapping_holds** uses the mat file from find_holds to plot the decay curve for all the holds both in linear space and log(time) space

Typically, **readUCSCtriax** and **calc_mu_UCSC** are used for each experiment. For example: 

                            test1 = readUCSCtriax('UC0001.csv');  
                            [test1_final, start_time, end_time] = calc_mu_UCSC(test1, 1, 'UC0001');
