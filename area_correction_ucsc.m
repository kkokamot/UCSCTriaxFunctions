%% Find Shear Stress for 45 or L or Off Sample
function [MR_shear, MR_shear_dispcorr] = area_correction_ucsc(MR_load, Pc_load, angle, area)
    if angle == 'L' | angle == 90
        MR_force = (.0381/2)^(2)*pi*(MR_load); 
        %38.1mm diameter; length = ~48mm %2mm for indium block
        %(38.1*48) mm^2 = .001829 m^2
        MR_shear_dispcorr = (MR_force./area); %n/m^2 -> Pa
        MR_shear = MR_force./0.001829;
    elseif angle == 30
        MR_force = (.0381/2)^2*pi*MR_shear;
        MR_shear = MR_force/(pi*1.732*1.5); %this will need to be changed once UCSC gets 45s
        MR_shear_dispcorr = (MR_force./area); %n/m^2 -> Pa

        Pc_force = (0.0381/2)^2*pi*Pc_load;
        Pc_load_ac = Pc_force/(pi*1.732*1.5);
        MR_shear_dispcorr = (MR_force./area); %n/m^2 -> Pa
    else
        print('Acceptable angle inputs: "L", 90, 45, "45"')
    end