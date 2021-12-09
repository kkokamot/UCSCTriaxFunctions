%% Find Shear Stress for 45 or L or Off Sample
function [MR_shear, MR_shear_dispcorr] = area_correction(MR_load, angle, area)
    if angle == 'L' | angle == 90
        MR_force = (.0381/2)^(2)*pi*(MR_load); 
        %38.1mm diameter; length = ~48mm %2mm for indium block
        %accurate?
        %38.1*50 = 1,524 mm^2 = .001524 m^2
        MR_shear_dispcorr = MR_force./area;
        MR_shear = MR_force./0.001524;
    elseif angle == 45
        MR_force = (.0381/2)^2*pi*MR_load;
        MR_shear = MR_force/0.00125; %this probably needs to be changed for UCSC
%         Pc_force = (0.035*0.035)*Pc_load;
%         Pc_load_ac = Pc_force/0.00125;
    else
        print('Acceptable angle inputs: "L", 90, 45, "45"')
    end