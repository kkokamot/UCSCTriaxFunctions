% detrend friction step or hold
function [single_df, pf] = detrend_test(single_df, ss_mu_value ,fig_num)
    f = figure(fig_num);
    f.WindowState = 'maximized';
    plot(single_df.LoadingPlattenDispHighGain, single_df.friction)
    title('Detrend?')
    test = input("Detrend? ", "s");
    if test == 'N'
        pf = [0, 0];
    else
        while test == 'Y' | test2 == 'N'
            figure(fig_num)
            plot(single_df.LoadingPlattenDispHighGain, single_df.friction)
            hold on
            title('Select detrend points')
            [dx, dy] = ginput(2);
            pf = polyfit(dx, dy, 1);
            pv = polyval(pf, single_df.LoadingPlattenDispHighGain);
            plot(single_df.LoadingPlattenDispHighGain, pv)
            plot(single_df.LoadingPlattenDispHighGain, single_df.friction - pv + ss_mu_value)
            test2 = input("Accept detrend? ","s");
            test = 'N';
            hold off
        end
        single_df.friction = single_df.friction - pv + ss_mu_value;
    end
end
    
