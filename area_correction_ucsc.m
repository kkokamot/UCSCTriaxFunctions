%% Find Shear Stress for 45 or L or Off Sample
function [MR_shear, MR_shear_dispcorr] = area_correction_ucsc(MR_load, angle, area)
    if angle == 'L' | angle == 90
        MR_force = (.0381/2)^(2)*pi*(MR_load); 
        %38.1mm diameter; length = ~48mm %2mm for indium block
        %(38.1*48) mm^2 = .001829 m^2
        MR_shear_dispcorr = (MR_force./area); %n/m^2 -> Pa
        MR_shear = MR_force./0.001829;
    elseif angle == 45
        MR_force = (.0381/2)^2*pi*MR_shear;
        MR_shear = MR_force/0.00125; %this will need to be changed once UCSC gets 45s
%         Pc_force = (0.035*0.035)*Pc_load;
%         Pc_load_ac = Pc_force/0.00125;
    else
        print('Acceptable angle inputs: "L", 90, 45, "45"')
    end