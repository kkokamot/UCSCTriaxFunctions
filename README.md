# UCSC Triax Functions

These functions are used in analyzing friction data from the UCSC triaxial deformation apparatus in matlab.  

The function **readUCSCtriax** reads in autolab data as a matlab table (ignores headerlines). 

**calc_mu_UCSC** calculates friction for the L-block setup. It saves a figure of friction calculated from the axial intensifier pressure (Pac) and from the load cell. The final experiment table is the initial experiment table with added columns for shear, shear as calculated form the axial control pressure (shear_Pac), friction, and friction as calculated from the axial control pressure (friction_Pac).

**find_holds** creates a mat file of all the hold locations.

**find_k_holds** uses the mat file from find_holds to find the stiffness of each hold as well as delta_mu, delta_mu_c for various steady state possibilities.

**plot_overlapping_holds** uses the mat file from find_holds to plot the decay curve for all the holds both in linear space and log(time) space

Typically, **readUCSCtriax** and **calc_mu_UCSC** are used for each experiment. For example: 

                            test1 = readUCSCtriax('UC0001.csv');  
                            [test1_final] = calc_mu_UCSC(test1, 1, 'UC0001');
