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
    ylim([max(file_df.friction) - ylim_diff, max(file_df.friction)])
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
    ylim([max(file_df.friction) - ylim_diff, max(file_df.friction)])
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
        hold_df = file_df(hold_indices,:);
        f = figure();
        f.WindowState = 'maximized';
        plot(file_df.Time(hold_indices), file_df.friction(hold_indices))
        hold on
        xlabel('Time (s)')
        ylabel('Friction (\mu)')
        title('Pick start and end of hold')
        clear Time_2 mu_2 I_hold
        [Time_2, mu_2] = ginput(2);
        [~,~, I_hold] = after_ginput(Time_2, mu_2, hold_df.Time, hold_df.friction);
        start_hold_T(i) = hold_df.Time(I_hold(1));
        end_hold_T(i) = hold_df.Time(I_hold(2));
        start_hold_mu(i) = hold_df.friction(I_hold(1));
        end_hold_mu(i) = hold_df.friction(I_hold(2));
        start_hold_disp(i) = hold_df.LoadingPlattenDispHighGain(I_hold(1));
        end_hold_disp(i) = hold_df.LoadingPlattenDispHighGain(I_hold(2));
        plot(start_hold_T(i), start_hold_mu(i), 'o')
        hold on
        plot(end_hold_T(i), end_hold_mu(i), 'square')
        hold off
    end
    save(save_file + "hold_picks.mat", "end_hold_mu", "end_hold_T", "start_hold_mu", "start_hold_T", "start_hold_disp", "end_hold_disp", '-mat')
end
