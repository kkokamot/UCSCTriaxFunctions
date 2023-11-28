function find_ss_and_max(file_df, exp_num)
    close all 
    check_for_previous = isfile("UC" + exp_num + "healing_picks.mat");
    if check_for_previous == 1
        check = input('There already exists a file with previously found steady state values. Do you want to continue? [N] ', 's');
        if isempty(check)
            check = 'N';
        end
        if check == 'N'
            return
        end
    end
    
    hold_picks = load("UC" + exp_num + "hold_picks.mat");
    [row_start,~] = find(file_df.OG_Index == hold_picks.start_hold_index);
    [row_end,~] = find(file_df.OG_Index == hold_picks.end_hold_index);

    T_hold_f = file_df.Time(row_start) ;%hold_picks.start_hold_T;
    T_end_f = file_df.Time(row_end);
    start_friction_f = hold_picks.start_hold_mu;
    end_friction_f = hold_picks.end_hold_mu;
    disp_start_f = file_df.LoadingPlattenDispHighGain(row_start)*1000;
    disp_end_f = file_df.LoadingPlattenDispHighGain(row_end)*1000;

    %figure(fig_num)
    %plot(file_df.Time, file_df.friction, T_hold_f, start_friction_f, 'o', T_end_f, end_friction_f, 'o')
    ss_post_mu = zeros(1, length(T_hold_f)); ss_post_T = zeros(1, length(T_hold_f));
    ss_post_disp = zeros(1, length(T_hold_f)); ss_post_index = zeros(1, length(T_hold_f));
    heal_mu = zeros(1, length(T_hold_f)); heal_T = zeros(1, length(T_hold_f));
    heal_disp = zeros(1, length(T_hold_f)); heal_index = zeros(1, length(T_hold_f));
    detrend_pf = zeros(2, length(T_hold_f));
    for i = 1:length(T_hold_f)
        hold_indices = (file_df.Time > T_hold_f(i)-10 & file_df.Time < T_end_f(i)+100);
        hold_df = file_df(hold_indices,:);
        f = figure();
        plot(hold_df.LoadingPlattenDispHighGain, hold_df.friction)
        [hold_df, detrend_pf(:,i)] = detrend_test(hold_df, hold_picks.start_hold_mu(i), 1);
        f.WindowState = 'maximized';
        plot(hold_df.LoadingPlattenDispHighGain, hold_df.friction)
        hold on
        xlabel('Time (s)')
        ylabel('friction (\mu)')
        title('Pick maximum healing value and steady state post')
        [Time_1, mu_1] = ginput(2);
        [~,~, I_post] = after_ginput(Time_1, mu_1, hold_df.LoadingPlattenDispHighGain, hold_df.friction);
        ss_post_T(i) = hold_df.Time(I_post(2));
        ss_post_mu(i) = hold_df.friction(I_post(2));
        ss_post_disp(i) = hold_df.LoadingPlattenDispHighGain(I_post(2));
        ss_post_index(i) = hold_df.OG_Index(I_post(2));
        heal_T(i) = hold_df.Time(I_post(1));
        heal_mu(i) =hold_df.friction(I_post(1));
        heal_disp(i) =hold_df.LoadingPlattenDispHighGain(I_post(1));
        heal_index(i) = hold_df.OG_Index(I_post(1));

        plot(ss_post_T(i), ss_post_mu(i), 'o')
        plot(heal_T(i), heal_mu(i),'o')
        hold off
    end
    
    delta_mu_post = heal_mu - ss_post_mu;
    delta_mu_pre = heal_mu - hold_picks.start_hold_mu;
    delta_mu_c_post = ss_post_mu - hold_picks.end_hold_mu;
    delta_mu_c_pre = hold_picks.start_hold_mu - hold_picks.end_hold_mu;    
    hold_time = T_end_f - T_hold_f;

    pf_post = polyfit(hold_time,delta_mu_post, 1);
    pf_pre = polyfit(hold_time,delta_mu_pre, 1);
    pf_post_c = polyfit(hold_time,delta_mu_c_post, 1);
    pf_pre_c = polyfit(hold_time,delta_mu_c_pre, 1);
    figure(1)
    subplot(2,1,1)
    semilogx(hold_time, delta_mu_post, 'o')
    hold on
    text(30, max([delta_mu_post,delta_mu_pre]), "\beta = " + string(pf_post(1)), 'Color','b')
    semilogx(hold_time, delta_mu_pre, 'o')
    text(30, max([delta_mu_post,delta_mu_pre])-range(max(delta_mu_post,delta_mu_pre))/3, "\beta = " + string(pf_pre(1)), 'Color','r')
    ylabel('Healing')
    xlabel('Hold Time (s)')
    subplot(2,1,2)
    semilogx(hold_time, delta_mu_c_post, 'o')
    hold on
    semilogx(hold_time, delta_mu_c_pre, 'o')
    ylabel('Relaxation')
    xlabel('Hold Time(s)')
    legend('Post hold steady state', 'Pre hold steady state')

    save("UC" + exp_num + "healing_picks.mat", "ss_post_mu", "ss_post_index", "heal_mu", "heal_index", "hold_time", "delta_mu_post", "delta_mu_pre", "delta_mu_c_post", "delta_mu_c_pre", "detrend_pf", '-mat')
end
