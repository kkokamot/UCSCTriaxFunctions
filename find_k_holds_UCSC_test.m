function [k_loadup, k_reload, hold_time, delta_mu, delta_mu_c] = find_k_holds_UCSC_test(file_df, exp_num, fig_num, title_text)
    %this function finds the stiffness of loadup, reload, hold times, healing, and relaxation of an experiment
    %
    %Inputs:
    %file_df: an experiment in table format. This should already be processed to includefile_df.friction values
    %fig_num: figure number of first figure (figures numbered lower than fig_num will not be changed, while figures numbered higher than fig_num will be overwritten)
    %title_text: the title for the stiffness figure output
    %save_file: the title of the mat file output
    %dc: True/False input for whether to use displacement control
    %Note: start (negative) and end (postive) thresholds are typically around 4
    %but depend on movmean, so if you change movmean parameters then
    %thresholds must be adjusted
    %
    %Outputs:
    %k_loadup: stiffness of the system when loading the sample
    %k_reload: stiffness of the system when reloading the sample (during a
    %re-slide)
    %hold_time: hold times
    %delta_mu: healing values with steady state being defined before the
    %slide hold slide
    %delta_mu_c: relaxation values with steady state being defined after
    %the slide hold slide
    %Note: this function saves a mat file of all of these
    %parameters and more. This includes delta_mu's and delta_mu_c's that
    %are defined with a steady state at different positions (after hold,
    %fit as a point underneath maximum healing)
    hold_picks = load("UC" + exp_num + "hold_picks.mat");
   

    
    figure(fig_num)
    file_df.LoadingPlattenDispHighGain = file_df.LoadingPlattenDispHighGain*1000;
    plot(file_df.LoadingPlattenDispHighGain, file_df.friction)
    xlabel('Displacement')
    ylim([0 1])
    title('Input load up points')
    [disp_loadup, mu_loadup] = ginput(2);
    [disp_loadup, mu_loadup ,~] = after_ginput(disp_loadup,mu_loadup, file_df.LoadingPlattenDispHighGain,file_df.friction);
    loadup_disp = file_df.LoadingPlattenDispHighGain(file_df.LoadingPlattenDispHighGain > disp_loadup(1) & file_df.LoadingPlattenDispHighGain < disp_loadup(2));
    loadup_fric =file_df.friction(file_df.LoadingPlattenDispHighGain > disp_loadup(1) & file_df.LoadingPlattenDispHighGain < disp_loadup(2));
    [pf, ~] = polyfit(loadup_disp,loadup_fric,1);
    k_loadup = pf(1);
    k_loadup_fit = k_loadup.*loadup_disp + pf(2);
    
    T_hold_f = hold_picks.start_hold_T;
    T_end_f = hold_picks.end_hold_T;
    start_friction_f = hold_picks.start_hold_mu;
    end_friction_f = hold_picks.end_hold_mu;
    disp_start_f = hold_picks.start_hold_disp*1000;
    disp_end_f = hold_picks.end_hold_disp*1000;

    figure(fig_num+1)
    plot(file_df.Time,file_df.friction, T_hold_f, start_friction_f, 'o', T_end_f, end_friction_f, 'o')
    xlabel('Time (s)')
    ylabel('\mu')
    
    %get hold time, healing, and relaxation values
    hold_time = T_end_f - T_hold_f;
    start_window = T_hold_f - 20;
    end_window = T_hold_f + hold_time + 20;
    delta_mu = zeros(1,length(hold_time));
    delta_mu_sspost = zeros(1,length(hold_time));
    delta_mu_ssmid = zeros(1,length(hold_time));
    delta_mu_c = zeros(1,length(hold_time));
    delta_mu_c_sspost = zeros(1,length(hold_time));
    delta_mu_c_ssmid = zeros(1,length(hold_time));
    ss_value_post = zeros(1,length(hold_time));
    ss_value_mid = zeros(1,length(hold_time));
    relax_value = end_friction_f;
    healing_value = zeros(1,length(hold_time));
    accept_list = zeros(1,length(hold_time));

    ss_time = zeros(2,length(hold_time)); ss_disp = zeros(2,length(hold_time));
    ss_time_post = zeros(2,length(hold_time)); ss_disp_post = zeros(2,length(hold_time));
    
    r_time = T_end_f; r_disp = disp_end_f;
    ss_value = start_friction_f;
    h_time = zeros(1,length(hold_time)); h_disp = zeros(1,length(hold_time));
    for i = 1:length(hold_time)
        window_df = file_df(file_df.Time < end_window(i) & file_df.Time > T_hold_f(i)+10,:);
        steadystate_df = file_df(file_df.Time < start_window(i) + 8 & file_df.Time > start_window(i) +2.5,:);
        steadystate_df_post = file_df(file_df.Time < end_window(i) + 8 & file_df.Time > end_window(i) +2.5,:);
        if length(steadystate_df_post.Time) == 0
            steadystate_df_post = file_df(file_df.Time < end_window(i)+8 & file_df.Time > end_window(i),:);
        end

        ss_mu_mean = movmean(steadystate_df.friction, 50);
        ss_mu_mean_post = movmean(steadystate_df_post.friction, 50);
        pf = polyfit(steadystate_df.LoadingPlattenDispHighGain, ss_mu_mean,1);
        pv = polyval(pf, steadystate_df.LoadingPlattenDispHighGain);
        plot(steadystate_df.LoadingPlattenDispHighGain, ss_mu_mean, steadystate_df.LoadingPlattenDispHighGain, pv);
        plot(steadystate_df_post.LoadingPlattenDispHighGain, ss_mu_mean_post)
        [healing_value(i),h_ind] = max(window_df.friction);
        %window_df.friction = window_df.friction - pv2;
        h_time(i) = window_df.Time(h_ind);
        h_disp(i) = window_df.LoadingPlattenDispHighGain(h_ind);
        ss_time(:,i) = [steadystate_df.Time(1), steadystate_df.Time(end)];
        ss_disp(:,i) = [steadystate_df.LoadingPlattenDispHighGain(1), steadystate_df.LoadingPlattenDispHighGain(end)];
        ss_time_post(:,i) = [steadystate_df_post.Time(1), steadystate_df_post.Time(end)];
        ss_disp_post(:,i) = [steadystate_df_post.LoadingPlattenDispHighGain(1), steadystate_df_post.LoadingPlattenDispHighGain(end)];
        ss_value_post(i) = min(steadystate_df_post.friction);
        
        % get steady state value at the same time as the healing value from
        % a line connecting steady state value before hold to after hold
        ss_slope = (steadystate_df_post.friction(1) - steadystate_df.friction(end))/(steadystate_df_post.Time(1) - steadystate_df.Time(end));
        yint_ss = steadystate_df_post.friction(1) - ss_slope*steadystate_df_post.Time(1);
        ss_value_mid(i) = h_time(i)*ss_slope + yint_ss;
        
    end
 
    
    for i = 1:length(hold_time)
        window_df = file_df(file_df.Time < end_window(i) & file_df.Time > T_hold_f(i),:);
        whole_hold_df = file_df(file_df.Time < end_window(i) + 100 & file_df.Time > T_hold_f(i) - 100,:);
        figure(fig_num+3+i)
        subplot(2,1,1)
        plot(window_df.LoadingPlattenDispHighGain, window_df.friction)
        hold on
        plot(h_disp(i), ss_value_mid(i),'o')
        plot(h_disp(i), ss_value_post(i), 'o')
        plot(h_disp(i), healing_value(i), 'o')
        plot(r_disp(i), relax_value(i),'o')
        hold on
        plot(disp_start_f(i), start_friction_f(i), 'o')
        plot(disp_end_f(i), end_friction_f(i), 'o')
        xlabel('Displacement (mm)')
        ylabel('\mu')
        hold off
        
        subplot(2,1,2)
        plot(whole_hold_df.Time, whole_hold_df.friction)
        hold on
        plot(h_time(i), ss_value_mid(i),'o')
        plot(h_time(i), ss_value_post(i), 'o')
        plot(h_time(i), healing_value(i), 'o')
        plot(r_time(i), relax_value(i),'o')
        xlabel('Time (s)')
        ylabel('\mu')
        hold off
        
        accept_list(i) = input('Is this hold acceptable? Y/N [Y]: ', 's');
        if isempty(accept_list(i))
            accept_list(i) = 'Y';
        end
        
        delta_mu(i) = healing_value(i) - ss_value(i);
        delta_mu_sspost(i) = healing_value(i) - ss_value_post(i);
        delta_mu_ssmid(i) = healing_value(i) - ss_value_mid(i);
        delta_mu_c(i) = ss_value(i) - relax_value(i);
        delta_mu_c_sspost(i) = ss_value_post(i) - relax_value(i);
        delta_mu_c_ssmid(i) = ss_value_mid(i) - relax_value(i);
    end
    
    delta_mu = delta_mu(accept_list == 'Y');
    delta_mu_sspost = delta_mu_sspost(accept_list == 'Y');
    delta_mu_ssmid = delta_mu_ssmid(accept_list == 'Y');
    delta_mu_c = delta_mu_c(accept_list == 'Y');
    delta_mu_c_sspost = delta_mu_c_sspost(accept_list == 'Y');
    delta_mu_c_ssmid = delta_mu_c_ssmid(accept_list == 'Y');
    hold_time = hold_time(accept_list == 'Y');
    %construct mid using steady state before holds
    
    %
    figure(fig_num+3)
    subplot(2,1,1)
    plot(file_df.Time, file_df.friction, ss_time', [ss_value' ss_value'], '-', r_time, relax_value, 'o', h_time, healing_value,'o')
    ylabel('\mu')
    xlabel('Time (s)')
    subplot(2,1,2)
    plot(file_df.LoadingPlattenDispHighGain, file_df.friction, ss_disp', [ss_value' ss_value'], '-', r_disp, relax_value, 'o', h_disp, healing_value,'o')
    %hold on
    %plot(ss_disp_post(floor(length(ss_disp_post)/2),:), ss_value_post,'k^')
    xlabel('Displacement (mm)')
    ylabel('\mu')
    saveas(gcf,["UC" + exp_num + "_healing_fits.fig"])

    figure(fig_num+4)
    subplot(3,1,1)
    semilogx(hold_time, delta_mu, 'o')
    xlabel('Hold Time (s)')
    ylabel('\Delta\mu')
    title('pre-hold steady state value')
    
    subplot(3,1,2)
    semilogx(hold_time, delta_mu_sspost,'o')
    xlabel('Hold Time (s)')
    ylabel('\Delta\mu')
    title('with post hold steady state value')
    
    subplot(3,1,3)
    semilogx(hold_time, delta_mu_ssmid,'o')
    xlabel('Hold Time (s)')
    ylabel('\Delta\mu')
    title('fit steady state value')
    
    
    %fit reload for stiffness
    close(fig_num)
    figure(fig_num)
    plot(file_df.LoadingPlattenDispHighGain, file_df.friction, disp_start_f, start_friction_f, 'o', disp_end_f, end_friction_f, 'o')
    ylim([0 1])
    hold on
    figure(fig_num+2)
    plot(file_df.Time, file_df.friction, T_hold_f, start_friction_f, 'o', T_end_f, end_friction_f, 'o')
    ylim([0 1])
    k_reload = zeros(length(disp_start_f),1);
    figure(fig_num)
    for i = 1:length(disp_start_f)
        reload_disp = file_df.LoadingPlattenDispHighGain(file_df.LoadingPlattenDispHighGain > disp_end_f(i)+2.5 & file_df.LoadingPlattenDispHighGain < disp_end_f(i) +15);
        reload_fric = file_df.friction(file_df.LoadingPlattenDispHighGain > disp_end_f(i)+2.5 & file_df.LoadingPlattenDispHighGain < disp_end_f(i) +15);
        [pf_vals, ~] = polyfit(reload_disp, reload_fric,1);
        k_reload(i) = pf_vals(1);
        k_fit = polyval(pf_vals, reload_disp);
        plot(reload_disp,k_fit, 'r-')
        text(disp_end_f(i), end_friction_f(i)+0.03, num2str(k_reload(i),2))
        hold on
    end
    plot(loadup_disp, k_loadup_fit,'r-')
    text(disp_loadup(1), mu_loadup(1), num2str(k_loadup,2))
    xlabel('Displacement (\mum)')
    ylabel('\mu')
    title(title_text)
    savefig(["UC" + exp_num + "_kFits.fig"])
    saveas(gcf,["UC" + exp_num + "_kFits.jpg"])
    save(["UC" + exp_num + "_kFits.mat"], 'k_loadup', 'k_reload', 'file_df', 'hold_time', 'disp_start_f', 'start_friction_f', 'ss_value', 'delta_mu', 'delta_mu_c', 'ss_value_post', 'delta_mu_sspost', 'delta_mu_c_sspost','delta_mu_ssmid', 'delta_mu_c_ssmid')
    hold off
end