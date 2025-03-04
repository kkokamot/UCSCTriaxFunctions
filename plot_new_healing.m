function [heal_picks] = plot_new_healing(fig_num, exp_num,legend_name, color, marker, remove_post_3000)
    heal_picks = load("UC" + exp_num + "healing_picks.mat");
    hold_picks = load("UC" + exp_num + "hold_picks.mat");
    load("UC" + sprintf('%04d', exp_num) + ".mat");
    if size(heal_picks.hold_time,1) > 1
        heal_picks.hold_time = heal_picks.hold_time';
    end
    if remove_post_3000 == true
        idx_end = find(round(heal_picks.hold_time,-2) == 3000);
    elseif remove_post_3000 == false
        idx_end = length(heal_picks.hold_time);
    end
    hold_times = sort(heal_picks.hold_time(1:idx_end));
    
    shear = file_df.shear(ismember(file_df.OG_Index, hold_picks.start_hold_index)) - file_df.shear(ismember(file_df.OG_Index, hold_picks.end_hold_index));
    % plot a relationship between LVDT1/2 and delta_mu_c
    total_LVDT1 = file_df.LVDT1(ismember(file_df.OG_Index, hold_picks.end_hold_index)) - file_df.LVDT1(ismember(file_df.OG_Index, hold_picks.start_hold_index));
    total_LVDT2 = file_df.LVDT2(ismember(file_df.OG_Index, hold_picks.end_hold_index)) - file_df.LVDT2(ismember(file_df.OG_Index, hold_picks.start_hold_index));

    total_LVDT1_r = total_LVDT1(total_LVDT1 > 0);
    total_LVDT2_r = total_LVDT2(total_LVDT2 > 0);
    LVDT1_delta_mu_c = heal_picks.delta_mu_c_pre(total_LVDT1 > 0);
    LVDT2_delta_mu_c = heal_picks.delta_mu_c_pre(total_LVDT2 > 0);
    LVDT1_delta_mu = heal_picks.delta_mu_pre(total_LVDT1 > 0);
    LVDT2_delta_mu = heal_picks.delta_mu_pre(total_LVDT2 > 0); 
    LVDT1_shear = shear(total_LVDT1 > 0);
    LVDT2_shear = shear(total_LVDT2 > 0);
    LVDT1_holdtimes = heal_picks.hold_time(total_LVDT1 > 0);
    LVDT2_holdtimes = heal_picks.hold_time(total_LVDT2 > 0);

    figure(fig_num)
    subplot(3,2,1)
    plot(total_LVDT1_r.*10^3, LVDT1_delta_mu_c, 'o', MarkerFaceColor = color, MarkerEdgeColor='none')
    xlabel('Onboard LVDT1 (\mum)')
    ylabel('\Delta\mu_c')
    hold on
    subplot(3,2,2)
    plot(total_LVDT2_r.*10^3, LVDT2_delta_mu_c, 's', MarkerFaceColor = color, MarkerEdgeColor='none')
    xlabel('Onboard LVDT2 (\mum)')
    ylabel('\Delta\mu_c')
    hold on
    subplot(3,2,3)
    plot(total_LVDT1_r.*10^3, LVDT1_delta_mu, 'o', MarkerFaceColor = color, MarkerEdgeColor='none')
    xlabel('Onboard LVDT1 (\mum)')
    ylabel('\Delta\mu')
    hold on
    subplot(3,2,4)
    plot(total_LVDT2_r.*10^3, LVDT2_delta_mu, 's', MarkerFaceColor = color, MarkerEdgeColor='none')
    xlabel('Onboard LVDT2 (\mum)')
    ylabel('\Delta\mu')
    hold on
    subplot(3,2,5)
    plot(total_LVDT1_r.*10^3, LVDT1_shear, 'o', MarkerFaceColor = color, MarkerEdgeColor='none')
    xlabel('Onboard LVDT1 (nm)')
    ylabel('\Tau')
    hold on
    subplot(3,2,6)
    plot(total_LVDT2_r.*10^3, LVDT2_shear, 's', MarkerFaceColor = color, MarkerEdgeColor='none')
    xlabel('Onboard LVDT2 (\mum)')
    ylabel('\Tau')
    hold on

    % plot a normalized healing
    fun = @(x,xdata)x(1)*log10(xdata/x(2)+1);
    x0 = [0.001 30];

    %x0 = [0.001 10^3];
    fit_pre = lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),heal_picks.delta_mu_pre(1:idx_end));
    pv_pre = fun(fit_pre, hold_times);

    comp_heal = heal_picks.delta_mu_pre(1:idx_end)./-heal_picks.delta_mu_c_pre(1:idx_end);
    fit_pre_comp = polyfit(log10(heal_picks.hold_time(1:idx_end)),comp_heal, 1); %lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),comp_heal);
    pv_pre_comp = polyval(fit_pre_comp, log10(hold_times)); 

    fit_pre_c = lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),-heal_picks.delta_mu_c_pre(1:idx_end));
    pv_pre_c = fun(fit_pre_c, hold_times);

    f = figure(fig_num + 1);
    f.WindowState = 'maximized';
    subplot(3,1,1)
    semilogx(heal_picks.hold_time(1:idx_end), heal_picks.delta_mu_pre(1:idx_end), marker, MarkerFaceColor = color, MarkerEdgeColor='none')
    hold on
    semilogx(hold_times, pv_pre, Color = color)
    text(30, max(heal_picks.delta_mu_pre(1:idx_end)) - range(heal_picks.delta_mu_pre(1:idx_end))/4, "\beta = " + string(round(fit_pre(1),4)) + "; T_c = " + string(round(fit_pre(2),2)), 'FontSize', 15, 'Color', color)
    %text(30, max(gca().YLim)-range(gca().YLim)/5, "\beta = " + string(pf_post(2)), "Color", "b")
    %text(100, max(gca().YLim)-range(gca().YLim)/5, "\beta = " + string(pf_pre(2)), "Color", "r")
    ylabel('Healing from ss_{pre}')
    title("Healing and Relaxation pre picks for Experiment #" + exp_num)
    set(gca,'FontSize',22)
    set(gca, 'LineWidth', 2)
    subplot(3,1,2)
    semilogx(heal_picks.hold_time(1:idx_end), comp_heal, marker, MarkerFaceColor = color, MarkerEdgeColor='none')
    hold on
    semilogx(hold_times, pv_pre_comp, Color = color)
    text(30, max(comp_heal) - range(comp_heal)/4, "\beta = " + string(round(fit_pre_comp(1),4)) + "; T_c = " + string(round(fit_pre(2),2)), 'FontSize', 15, 'Color', color)    
    ylabel('\Delta\mu * \Detla\mu_c * \mu_ss')
    subplot(3,1,3)
    semilogx(heal_picks.hold_time(1:idx_end), -heal_picks.delta_mu_c_pre(1:idx_end), marker,  MarkerFaceColor = color, MarkerEdgeColor='none')
    hold on
    semilogx(hold_times, pv_pre_c, 'DisplayName',legend_name, Color = color)
    text(30, max(-heal_picks.delta_mu_c_pre(1:idx_end)) - range(heal_picks.delta_mu_c_pre(1:idx_end))/4, "\beta\_c = " + string(round(fit_pre_c(1),3)) + "; T_c = " + string(round(fit_pre_c(2),2)), 'FontSize', 15, 'Color', color)
%    savefig("UC" + exp_num + "_HealRel_pre.fig")

    ylabel('Relaxation from ss_{pre}')
    xlabel('Hold Time (s)')
    set(gca,'FontSize',22)
    set(gca, 'LineWidth', 2)

    %heal_picks.fit_pre = fit_pre;
    %heal_picks.fit_post_c = fit_post_c;
    %heal_picks.fit_pre_c = fit_pre_c;

    %save("UC" + exp_num + "new_healing_picks.mat", '-struct', 'heal_picks')
end


