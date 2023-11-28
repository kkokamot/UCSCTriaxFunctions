# UCSC Triax Functions

These functions are used in analyzing friction data from the UCSC triaxial deformation apparatus in matlab.  

The function **readUCSCtriax** reads in autolab data as a matlab table (ignores headerlines) and creates a column for OG_Index. The OG_Index is used to keep track of any chosen location (e.g. start/stop of hold) in the future in order to be able to find the location in any subset of the data.

**displacement_correction** function calculates area change during shear. This is often not used because it is not clear how the area actually changes during the experiment (This assumes more area with displacement. But additional area is not occuring in places with teeth, so maybe less area with displacement? or does it somehow balance).

**area_correction_ucsc** calculates shear stress during the experiment by calculating the shear force and then dividing by the sample area. This returns both shear stress without the displacement corrected area and with the displacement corrected area.

**calc_mu_UCSC** uses both the displacement correction and area correction functions to calculate friction (mu). It plots displacement corrected friction as well as non displacement corrected friction. It also plots the area correction and the displacement correction to LVDT3 (compaction). It saves these figures as well as the final experiment table.  The final experiment table is the initial experiment table with added columns for shear, shear_dc (displacement corrected), comp (LVDT3 displacement corrected), friction, friction_dc (displacement corrected), and friction as calculated from the axial control pressure.

**find_holds** creates a mat file of the start and stop location of each hold. It does this first with a crude automatic method and then zooms into each hold, so you can hand-pick the best start and stop point.

**find_ss_and_max** creates a mat file of the post-hold steady state values (in order to compare to pre-hold steady state) and the peak friction on the re-slide (in order to calculate healing). In orer to use this, you must have already used find_holds.

**plot_overlapping_holds** uses the mat file from find_holds to plot the decay curve for all the holds both in linear space and log(time) space

In addition, there are lots of other plotting tools.

Typically, **readUCSCtriax** and **calc_mu_UCSC** are used for each experiment. For example: 

                            test1 = readUCSCtriax('UC0001.csv');  
                            [test1_final, start_time, end_time] = calc_mu_UCSC(test1, 1, 'UC0001');

To measure healing you can use these functions.

                            find_holds(test1, auto_find_threshold, figure_num, '[enter exp_name]')
                            find_ss_and_max(test1, "[enter exp_num]")
                            plot_healing(figure_num, [enter_exp_num], '[enter plot title]', color)
