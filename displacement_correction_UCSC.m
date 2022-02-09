%% calculates area with displacement corrections
% inputs: 
%        -file_df: the 
function [area, comp_fin, start_time, end_time, load_at_start, load_at_end] = displacement_correction_UCSC(file_df, save_name)
    Time = file_df.Time;
    disp_HG = file_df.LoadingPlattenDispHighGain;
    disp_LG = file_df.LoadingPlattenDisplacement;
    shear = file_df.LoadCell;
    comp = file_df.LVDT3+10;

    figure(1)
    subplot(2,1,1)
    plot(Time, disp_LG)
    xlabel('Displacement (mm)')
    ylabel('Shear Load (MPa)')
    %ylim([-1,3])
    subplot(2,1,2)
    plot(Time,shear)
    xlabel('Time')
    ylabel('Shear Load (MPa)')
    ylim([-1,3])
    
    title('Pick the start of sample displacement')
    [start_time, load_at_start] = ginput(1);
%     figure(1)
%     subplot(2,1,1)
%     ylim([max(shear) - range(shear)/4, max(shear) + 2])
%     subplot(2,1,2)
%     ylim([max(shear) - range(shear)/4, max(shear) + 2])
    title('Pick end of sample displacement')
    [end_time, load_at_end] = ginput(1);

    I = (Time > start_time & Time < end_time);
    exp_disp = disp_HG(I);
    exp_disp = exp_disp - exp_disp(1);
    exp_time = Time(I);
    exp_comp = comp(I);

    L_width = 38.1 * 0.001; %1.5" is 38.1mm

    L_height = (48-exp_disp) * 0.001; %50 mm - 1 mm for each indium block - disp

    comp_corr = ((exp_comp).^2 - (exp_disp).^2).^(1/2)
    area_corr = L_height * L_width;

    area = NaN(length(disp_HG), 1);
    area(I) = area_corr;
    comp_fin = comp;
    comp_fin(I) = comp_corr;

    f = figure(1);
    %f.WindowState = 'maximized';
    subplot(2,1,1)
    plot(exp_time,area_corr);
    xlabel('Time (s)')
    ylabel('Area (m^2)')
    subplot(2,1,2)
    plot(exp_time, comp_corr);
    hold on
    plot(exp_time,comp);
    xlabel('Time (s)')
    ylabel('Compaction (mm)')
    try
        saveas(1, save_name + '_disp_corrections.jpg')
        savefig(save_name + '_disp_corrections.fig')
    catch
        save_name = convertCharsToStrings(save_name);
        saveas(1, save_name + '_disp_corrections.jpg')
        savefig(save_name + '_disp_corrections.fig')
    end

