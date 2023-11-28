function plot_holds_per_length_UCSC(one_length, file_df, exp_num, fig_num, color)
    hold_picks = load("UC" + exp_num + "hold_picks.mat");
    heal_picks = load("UC" + exp_num + "healing_picks.mat");
    try
        start_hold_T = hold_picks.start_hold_T;
        end_hold_T = hold_picks.end_hold_T;
        hold_lengths = end_hold_T - start_hold_T;
    catch
        hold_lengths = zeros(1,length(hold_picks.end_hold_index));
        start_hold_T  = zeros(1,length(hold_picks.end_hold_index));
        end_hold_T = zeros(1,length(hold_picks.end_hold_index));
        for k = [1:length(hold_picks.end_hold_index)]
            start_hold_T(k) = file_df.Time(file_df.OG_Index == hold_picks.start_hold_index(k));
            end_hold_T(k) = file_df.Time(file_df.OG_Index == hold_picks.end_hold_index(k));
            hold_lengths(k) = end_hold_T(k) - start_hold_T(k);
        end
    end
    try
        i = (round(hold_lengths,-1) == one_length);
        hold_indices = (file_df.Time > start_hold_T(i)-10 & file_df.Time < end_hold_T(i)+100);
        if heal_picks.detrend_pf(1) ~= 0
            pv = polyval(heal_picks.detrend_pf(:,i)', file_df.LoadingPlattenDispHighGain(hold_indices));
            friction = (file_df.friction(hold_indices) - pv);
            friction = friction - friction(1);
        else
            friction = file_df.friction(hold_indices);
            friction = friction - friction(1);
        end
        figure(fig_num)
        %subplot(1,2,1)
        plot(file_df.LoadingPlattenDispHighGain(hold_indices)-file_df.LoadingPlattenDispHighGain(find(hold_indices,1,'first')), friction, Color = color)
        hold on
        %subplot(1,2,2)
        %plot(file_df.Time(hold_indices)-file_df.Time(find(hold_indices,1,'first')), friction, Color = color)
        %hold on
        %figure(fig_num)
        %subplot(1,2,1)
        xlabel('Displacement (mm)', 'FontSize',18)
        ylabel('Friction (\mu - \mu(Time of Hold))','FontSize',18)
        %subplot(1,2,2)
        %xlabel('Time (s)')
        %ylabel('Friction (\mu - \mu(Time of Hold))')
        title("Hold = " + one_length, 'FontSize',22)
        ax = gca();
        ax.LineWidth = 3;
    catch
        "No hold for " + one_length + "s"
    end
end