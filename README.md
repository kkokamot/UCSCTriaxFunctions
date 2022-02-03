# UCSCTriaxFunctions

These functions are used in analyzing friction data from the UCSC triaxial deformation apparatus in matlab.  
The function **readUCSCtriax** reads in autolab data as a matlab table (ignores headerlines). The **displacement_correction** function calculates area change during shear.  
The function **area_correction_ucsc** calculates shear stress during the experiment by calculating the shear force and then diving by the sample area. This returns both shear stress without the displacement corrected area and with the displacement corrected area.  
The **calc_mu_UCSC** function uses both the displacement correction and area correction functions to calculate friction (mu). It plots displacement corrected friction as well as non displacement corrected friction. It also plots the area correction and the displacement correction to LVDT3 (compaction). It saves these figures as well as the final experiment table.  
Typically, **readUCSCtriax** and **calc_mu_UCSC** are used for each experiment. For example: 

                            test1 = readUCSCtriax('UC0001.csv');  
                            [test1_final, start_time, end_time] = calc_mu_UCSC(test1, 1, 'UC0001');
