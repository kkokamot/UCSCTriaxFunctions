function plot_overlapping_holds_UCSC(file_df, exp_num, title_text)
    hold_picks = load("UC" + exp_num + "hold_picks.mat");
    for i = 1:length(hold_picks.start_hold_T)
        hold_indices = (file_df.Time > hold_picks.start_hold_T(i)-10 & file_df.Time < hold_picks.end_hold_T(i)+10);
        figure(1)
        subplot(1,2,1)
        plot(file_df.Time(hold_indices)-hold_picks.start_hold_T(i), file_df.friction(hold_indices)-hold_picks.start_hold_mu(i))
        hold on
        subplot(1,2,2)
        semilogx(file_df.Time(hold_indices)-hold_picks.start_hold_T(i), file_df.friction(hold_indices)-hold_picks.start_hold_mu(i))
        hold on
    end
    figure(1)
    subplot(1,2,1)
    xlabel('Time (s)')
    ylabel('Friction (\mu - \mu(Time of Hold))')
    subplot(1,2,2)
    xlabel('Time (s)')
    ylabel('Friction (\mu - \mu(Time of Hold))')
    title(title_text)
    savefig(["UC" + exp_num + "_overlappingHolds.fig"])
    saveas(gcf,["UC" + exp_num + "_overlappingHolds.jpg"])
    hold off
end
