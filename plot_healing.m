function [heal_picks] = plot_healing(fig_num, exp_num,legend_name, color, marker, remove_post_3000)
    heal_picks = load("UC" + exp_num + "healing_picks.mat");
    if size(heal_picks.hold_time,1) > 1
        heal_picks.hold_time = heal_picks.hold_time';
    end
    if remove_post_3000 == true
        idx_end = find(round(heal_picks.hold_time,-2) == 3000);
    elseif remove_post_3000 == false
        idx_end = length(heal_picks.hold_time);
    end
    hold_times = sort(heal_picks.hold_time(1:idx_end));

    fun = @(x,xdata)x(1)*log10(xdata/x(2)+1);
    x0 = [0.001 30];
    [fit_post, r2_post] = lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),heal_picks.delta_mu_post(1:idx_end));
    pv_post = fun(fit_post, hold_times);

    %x0 = [0.001 10^3];
    [fit_pre, r2_pre] = lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),heal_picks.delta_mu_pre(1:idx_end));
    pv_pre = fun(fit_pre, hold_times);

    [fit_post_c, r2_post_c] = lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),heal_picks.delta_mu_c_post(1:idx_end));
    pv_post_c = fun(fit_post_c, hold_times);

    [fit_pre_c, r2_pre_c] = lsqcurvefit(fun,x0,heal_picks.hold_time(1:idx_end),heal_picks.delta_mu_c_pre(1:idx_end));
    pv_pre_c = fun(fit_pre_c, hold_times);

    %
    fit_pre_boot = zeros(100,2);
    for i = [1:100]
        howmany = length(heal_picks.hold_time(1:idx_end));
        rand_idx = randi(howmany, howmany,1);
        x = heal_picks.hold_time(rand_idx);
        y = heal_picks.delta_mu_pre(1:idx_end);
        opts = optimset('Display','off');
        fit_pre_boot(i, :) = lsqcurvefit(fun, x0, x, y,[], [], opts);
    end
    fit_pre_std = std(fit_pre_boot(:,1));

    f = figure(fig_num);
    f.WindowState = 'maximized';
    subplot(2,1,1)
    p = semilogx(heal_picks.hold_time(1:idx_end), heal_picks.delta_mu_post(1:idx_end), marker, MarkerFaceColor = color, MarkerEdgeColor='none');
    set(get(get(p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
    hold on
    semilogx(hold_times, pv_post, 'DisplayName',legend_name, Color = color)
    text(30, max(heal_picks.delta_mu_post(1:idx_end)) - range(heal_picks.delta_mu_post(1:idx_end))/4, "\beta = " + string(round(fit_post(1),4)) + "; T_c = " + string(round(fit_post(2),2)), 'FontSize', 15, 'Color', color)
    ylabel('Healing from ss_{post}')
    title("Healing and Relaxation post picks for Experiment #" + exp_num)
    set(gca,'FontSize',22)
    set(gca, 'LineWidth', 2)
    subplot(2,1,2)
    semilogx(heal_picks.hold_time(1:idx_end), heal_picks.delta_mu_c_post(1:idx_end), marker,  MarkerFaceColor = color, MarkerEdgeColor='none')
    hold on
    semilogx(hold_times, pv_post_c, Color = color)
    text(30, max(heal_picks.delta_mu_c_post(1:idx_end)) - range(heal_picks.delta_mu_c_post(1:idx_end))/4, "\beta = " + string(round(fit_post_c(1),3)) + "; T_c = " + string(round(fit_post_c(2),2)), 'FontSize', 15, 'Color', color)
    ylabel('Relaxation from ss_{post}')

    xlabel('Hold Time (s)')
    set(gca,'FontSize',22)
    set(gca, 'LineWidth', 2)
    savefig("UC" + exp_num + "_HealRel_post.fig")

    f = figure(fig_num +1);
    f.WindowState = 'maximized';
    subplot(2,1,1)
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
    subplot(2,1,2)
    semilogx(heal_picks.hold_time(1:idx_end), heal_picks.delta_mu_c_pre(1:idx_end), marker,  MarkerFaceColor = color, MarkerEdgeColor='none')
    hold on
    semilogx(hold_times, pv_pre_c, Color = color)
    text(30, max(heal_picks.delta_mu_c_pre(1:idx_end)) - range(heal_picks.delta_mu_c_pre(1:idx_end))/4, "\beta = " + string(round(fit_pre_c(1),3)) + "; T_c = " + string(round(fit_pre_c(2),2)), 'FontSize', 15, 'Color', color)
    savefig("UC" + exp_num + "_HealRel_pre.fig")

    ylabel('Relaxation from ss_{pre}')
    xlabel('Hold Time (s)')
    set(gca,'FontSize',22)
    set(gca, 'LineWidth', 2)
    heal_picks.fit_post = fit_post;
    heal_picks.fit_pre = fit_pre;
    heal_picks.fit_post_c = fit_post_c;
    heal_picks.fit_pre_c = fit_pre_c;
    heal_picks.fit_pre_std = fit_pre_std;
    heal_picks.r2_pre = r2_pre;
    heal_picks.r2_pre_c = r2_pre_c;

    save("UC" + exp_num + "healing_picks.mat", '-struct', 'heal_picks')
end