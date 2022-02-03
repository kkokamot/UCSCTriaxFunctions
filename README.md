# UCSCTriaxFunctions

These functions are used in analyzing friction data from the UCSC triaxial deformation apparatus in matlab. The function readUCSCtriax.m reads in autolab data (ignores headerlines). The displacement_correction.m function calculates area change during shear. 

The function area_correction_ucsc.m calculates shear stress during the experiment by calculating the shear force and then diving by the sample area. This returns both shear stress without the displacement corrected area and with the displacement corrected area. 

calc_mu_UCSC calculates uses both the displacement correction and area correction to calculate friction (mu). It plots displacement corrected friction as well as non displacement corrected friction. It also plots the area correction and the displacement correction to LVDT3 (compaction).
