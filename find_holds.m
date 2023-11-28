function find_holds(file_df,acc_limit,fig_num, save_file)
    close all 
    check_for_previous = isfile(save_file + "hold_picks.mat");
    if check_for_previous == 1
        check = input('There already exists a file with previously found holds. Do you want to continue? [N] ', 's');
        if isempty(check)
            check = 'N';
        end
        if check == 'N'
            return
        end
    end
    
    % Automatically find holds
    %figure(fig_num)
    disp_d = resample(file_df.LoadingPlattenDispHighGain*1000,1,100);
    Time_d = resample(file_df.Time, 1, 100);
    friction_d = resample(file_df.friction, 1, 100);
    %plot(file_df.LoadingPlattenDispHighGain*1000, file_df.friction)
    
    %Time_d = Time_d(Time_d < cut_t(2) & Time_d > cut_t(1));
    %disp_d = disp_d(Time_d < cut_t(2) & Time_d > cut_t(1));
    %friction_d = friction_d(Time_d < cut_t(2) & Time_d > cut_t(1));
    acceleration = diff(diff(disp_d)./diff(Time_d));
    Time_a = Time_d(1:end);
    %figure(fig_num + 1);
    %plot(Time_d(3:end), acceleration)
    T_hold = Time_a(acceleration < -acc_limit);
    T_end = Time_a(acceleration > acc_limit);
    start_friction = friction_d(acceleration < -acc_limit);
    end_friction = friction_d(acceleration > acc_limit);

    figure(fig_num)
    plot(file_df.Time, file_df.friction, T_hold, start_friction, 'o', T_end, end_friction, 'o')
    title('Cut Time')
    ylim([0 1])
    [cut_t, ~] = ginput(2);
    T_hold_f = T_hold(T_hold < cut_t(2) & T_hold > cut_t(1));
    T_end_f = T_end(T_end<cut_t(2) & T_end > cut_t(1));
    start_friction_f = start_friction(T_hold < cut_t(2) & T_hold > cut_t(1));
    end_friction_f = end_friction(T_end < cut_t(2) & T_end > cut_t(1));

    close(fig_num)
    figure(fig_num)
    plot(file_df.Time, file_df.friction, T_hold_f, start_friction_f,'o')
    title('Remove start of hold bad picks (press enter when done)')
    ylim_diff = 2*(max(start_friction_f)-min(end_friction_f));
    ylim([max(start_friction_f) - ylim_diff, max(start_friction_f)])
    [x_bad1, y_bad1] = ginput();
    if x_bad1
        for j = 1:length(x_bad1)
            [~, ~,idx] = after_ginput(x_bad1(j),y_bad1(j), T_hold_f, start_friction_f);
            T_hold_f(idx) = [] ;
            start_friction_f(idx) = [] ;
        end
    end

    
    %manually remove bad picks at end of hold
    close(fig_num)
    figure(fig_num)
    plot(file_df.Time, file_df.friction, T_end_f, end_friction_f,'o')
    xlabel('Time (s)')
    ylabel('\mu')
    ylim([max(start_friction_f) - ylim_diff, max(start_friction_f)])
    title('Remove end of hold bad picks (press enter when done)')
    [x_bad2, y_bad2] = ginput();
    if x_bad2
        for j = 1:length(x_bad2)
            [~, ~,idx] = after_ginput(x_bad2(j), y_bad2(j), T_end_f, end_friction_f);
            T_end_f(idx) = [];
            end_friction_f(idx) = [];
        end
    end
    
    close(fig_num)
    %figure(fig_num)
    %plot(file_df.Time, file_df.friction, T_hold_f, start_friction_f, 'o', T_end_f, end_friction_f, 'o')
    start_hold_T = zeros(1, length(T_hold_f)); end_hold_T = zeros(1, length(T_hold_f));
    start_hold_mu =zeros(1, length(T_hold_f)); end_hold_mu = zeros(1, length(T_hold_f));
    start_hold_disp = zeros(1, length(T_hold_f)); end_hold_disp = zeros(1, length(T_hold_f));
    for i = 1:length(T_hold_f)
        hold_indices = (file_df.Time > T_hold_f(i)-10 & file_df.Time < T_end_f(i)+100);
        start_hold_indices = (file_df.Time > T_hold_f(i)-10 & file_df.Time < T_hold_f(i)+30);
        end_hold_indices = (file_df.Time > T_end_f(i)-10 & file_df.Time < T_end_f(i)+30);

        start_df = file_df(start_hold_indices,:);
        end_df = file_df(end_hold_indices,:);

        f = figure();
        f.WindowState = 'maximized';
        subplot(1,3,1)
        plot(file_df.Time(start_hold_indices), file_df.friction(start_hold_indices))
        hold on
        xlabel('Time (s)')
        ylabel('friction (\mu)')
        title('Pick start of hold')
        ax = gca();
        ylim_bottom = max(start_df.friction) - (max(start_df.friction) - min(end_df.friction))/4;
        ylim([ylim_bottom, ax.YLim(2)])
        clear Time_1 mu_1 I_start
        [Time_1, mu_1] = ginput(1);
        [~,~, I_start] = after_ginput(Time_1, mu_1, start_df.Time, start_df.friction);

        subplot(1,3,2)
        plot(file_df.Time(end_hold_indices), file_df.friction(end_hold_indices))
        xlabel('Time (s)')
        ylabel('friction (\mu)')
        hold on
        title('Pick end of hold')
        ax = gca();
        ylim_top = min(end_df.friction) + (max(start_df.friction) - min(end_df.friction))/4;
        ylim([ax.YLim(1), ylim_top])
        clear Time_2 mu_2 I_end
        [Time_2, mu_2] = ginput(1);
        [~,~, I_end] = after_ginput(Time_2, mu_2, end_df.Time, end_df.friction);
        
        start_hold_T(i) = start_df.Time(I_start);
        end_hold_T(i) = end_df.Time(I_end);
        start_hold_mu(i) = start_df.friction(I_start);
        end_hold_mu(i) = end_df.friction(I_end);
        start_hold_index(i) = start_df.OG_Index(I_start);
        end_hold_index(i) = end_df.OG_Index(I_end);

        subplot(1,3,3)
        plot(file_df.Time(hold_indices), file_df.friction(hold_indices))
        hold on
        plot(start_hold_T(i), start_hold_mu(i), 'o')
        plot(end_hold_T(i), end_hold_mu(i), 'square')
        hold off
    end
    save(save_file + "hold_picks.mat", "end_hold_mu", "end_hold_index", "start_hold_mu", "start_hold_index", '-mat')
end
