%%
function [file_df, area] = calc_mu_UCSC(file_df, fig_number, save_name)
    %%%
    %%%
    reply = input('Was pore pressure used during the experiment? Y/N [Y]: ', 's');

    if isempty(reply)
        reply = 'Y';
    end 

    %%% find friction

    % area change with displacement correction
    [area, ~, start_time, end_time, ~, ~] = displacement_correction_UCSC(file_df, fig_number+1, save_name);
    %area = 0.001829;
    % zero load cell
    %file_df.DifferentialStress = file_df.DifferentialStress  %- mean([load_at_start,load_at_end]);

    %file_df = file_df(file_df.Time > start_time & file_df.Time < end_time, :);
   % area = area(file_df.Time > start_time & file_df.Time < end_time);

    if reply == 'Y'
        [shear, shear_dc] = area_correction_ucsc(file_df.DifferentialStress,90, area);
        [shear_pac, ~] = area_correction_ucsc((file_df.AxialControlPressure - (file_df.ConfiningPressure/9.3))*(32.987/1.767), 90, area);
        friction = (shear)./(file_df.ConfiningPressure-file_df.PorePressure2);
        friction_pac = (shear_pac)./(file_df.ConfiningPressure - file_df.PorePressure2);
        friction_dc = (shear_dc)./(file_df.ConfiningPressure-file_df.PorePressure2);
    else
        [shear, shear_dc] = area_correction_ucsc(file_df.DifferentialStress,90, area);
        [shear_pac, ~] = area_correction_ucsc((file_df.AxialControlPressure - (file_df.ConfiningPressure/9.3))*(32.987/1.767), 90, area);
        friction = (shear)./(file_df.ConfiningPressure);
        friction_pac = (shear_pac)./(file_df.ConfiningPressure);        
        friction_dc = (shear_dc)./(file_df.ConfiningPressure);
    end

    %temp_table = table(shear, shear_dc, comp, friction, friction_dc, friction_pac);
    temp_table = table(shear, shear_dc, friction, friction_dc, friction_pac);
    file_df = [file_df temp_table];

    %%% plot friction values
    f = figure(fig_number);
    f.WindowState = 'maximized';
    subplot(2,1,1)
    plot(file_df.Time, file_df.ConfiningPressure);
    if reply == 'Y'
        hold on
        plot(file_df.Time, file_df.PorePressure2);
    end
    xlabel('Time (s)')
    ylabel('Pressure (MPa)')
    title('Cut time at beginning and end. The beginning point will zero all friction readings.')
    subplot(2,1,2)
    plot(file_df.Time, file_df.friction);
    ylabel('\mu')
    xlabel('Time (s)')
    ylim([-0.2 1])
    [limx, ~] = ginput(2);
    file_df = file_df(file_df.Time > limx(1) & file_df.Time < limx(2),:);
    
    file_df.friction = file_df.friction - file_df.friction(1);
    file_df.friction_dc = file_df.friction_dc - file_df.friction_dc(1);
    file_df.friction_pac = file_df.friction_pac - file_df.friction_pac(1);

    close(fig_number)
    f = figure(fig_number);
    f.WindowState = 'maximized';    
    subplot(2,1,1)
    plot(file_df.LoadingPlattenDispHighGain, file_df.friction_dc, 'LineWidth', 1.5)
    hold on
    plot(file_df.LoadingPlattenDispHighGain, file_df.friction, 'LineWidth', 1.5)
    plot(file_df.LoadingPlattenDispHighGain, file_df.friction_pac, 'LineWidth', 1.5)
    hold off
    ylabel('\mu')
    xlabel('High Gain Displacement (mm)')
    if reply == 'Y'
        title("Final Friction Values Pc_ = " + round(max(file_df.ConfiningPressure)) + ' P_p = ' + round(max(file_df.PorePressure2)))
    else
        title("Final Friction Values Pc_ = " + round(max(file_df.ConfiningPressure)) + ' P_p = 0')
    end
    legend([compose('displacement\ncorrected'), 'not corrected', 'from Pac'], 'Location', 'southeast')
    ax = gca();
    ax.LineWidth = 2;
    ax.FontSize = 20;
    subplot(2,1,2)
    plot(file_df.Time, file_df.friction_dc, 'LineWidth', 1.5)
    hold on
    plot(file_df.Time, file_df.friction, 'LineWidth', 1.5)
    plot(file_df.Time, file_df.friction_pac, 'LineWidth', 1.5)    
    hold off
    ylabel('\mu')
    xlabel('Time (s)')
    file_df.Time = file_df.Time - file_df.Time(1);
    ax = gca();
    ax.LineWidth = 2;
    ax.FontSize = 20;

    % save file_df as a mat file
    try
        save(save_name + '.mat', 'file_df')
    catch
        save_name = convertCharsToStrings(save_name);
        save(save_name + '.mat', 'file_df')
    end

    % save final friction values figure
    saveas(fig_number, save_name + '_correction_comparison.jpg')
    savefig(save_name + '_correction_comparison.fig')

    disp_um = file_df.LoadingPlattenDispHighGain*10^3;
    fric = file_df.friction;
    if reply == 'Y'
        normalstress = file_df.ConfiningPressure - file_df.PorePressure2;
    else
        normalstress = file_df.ConfiningPressure;
    end
    time = file_df.Time;
    save(save_name + '_RSFit.mat', 'disp_um', 'fric', 'normalstress', 'time')
end