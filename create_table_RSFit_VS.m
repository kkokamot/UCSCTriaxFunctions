exp_nums = []; % FILL IN

rs_table = (); %initiate empty table to fill
for i = 1:length(exp_nums)
    exp_num = exp_nums(i);
    load('UC00' + string(exp_num) + '.mat')
    load('UC' + string(exp_num) + 'healing_picks.mat')
    % get the velocity step fits
    vs = load('UC' + string(exp_num) + '_VS_RSFit.mat');

    % get the names of all velocity step fits (those that have VS in the
    % name of the fit)
    vs_names = who('*VS*','-file', char('UC' + string(exp_num) + '_VS_RSFit.mat'));
    num_vs = length(vs_names);   
    for k = 1:num_vs
            j = j +1;
            rs_table.exp_num(j) = exp_num;

            rs_table.sequence_no(j) = k;
            rs_table.InitialVelocity(j) = eval(sprintf('vs.%s.VelocityStepParameters.InitialVelocity',vs_names{k}));
            rs_table.FinalVelocity(j) = eval(sprintf('vs.%s.VelocityStepParameters.FinalVelocity',vs_names{k}));
            rs_table.b_aging(j) =  eval(sprintf('vs.%s.AgingLawParameters.b1(1)',vs_names{k})) + eval(sprintf('vs.%s.AgingLawParameters.b2(1)',vs_names{k}));
            rs_table.b_slip(j) = eval(sprintf('vs.%s.SlipLawParameters.b1(1)',vs_names{k})) + eval(sprintf('vs.%s.SlipLawParameters.b2(1)',vs_names{k}));
            rs_table.a_aging(j) = eval(sprintf('vs.%s.AgingLawParameters.a(1)',vs_names{k}));
            rs_table.a_slip(j) = eval(sprintf('vs.%s.SlipLawParameters.a(1)',vs_names{k}));
            rs_table.b_aging_err(j) =  eval(sprintf('vs.%s.AgingLawParameters.b1(2)',vs_names{k})) + eval(sprintf('vs.%s.AgingLawParameters.b2(2)',vs_names{k}));
            rs_table.b_slip_err(j) = eval(sprintf('vs.%s.SlipLawParameters.b1(2)',vs_names{k})) + eval(sprintf('vs.%s.SlipLawParameters.b2(2)',vs_names{k}));
            rs_table.a_aging_err(j) = eval(sprintf('vs.%s.AgingLawParameters.a(2)',vs_names{k}));
            rs_table.a_slip_err(j) = eval(sprintf('vs.%s.SlipLawParameters.a(2)',vs_names{k}));
            rs_table.stiffness_slip(j) = eval(sprintf('vs.%s.SlipLawParameters.stiffness(1)',vs_names{k}));
            rs_table.stiffness_slip_err(j) = eval(sprintf('vs.%s.SlipLawParameters.stiffness(2)',vs_names{k}));
            rs_table.stiffness_aging(j) = eval(sprintf('vs.%s.AgingLawParameters.stiffness(1)',vs_names{k}));
            rs_table.stiffness_aging_err(j) = eval(sprintf('vs.%s.AgingLawParameters.stiffness(2)',vs_names{k}));
            rs_table.Dc_aging(j) = eval(sprintf('vs.%s.AgingLawParameters.d_c1(1)',vs_names{k}));
            rs_table.Dc_aging_err(j) = eval(sprintf('vs.%s.AgingLawParameters.d_c1(2)',vs_names{k}));
            rs_table.Dc_slip(j) = eval(sprintf('vs.%s.SlipLawParameters.d_c1(1)',vs_names{k}));
            rs_table.Dc_slip_err(j) = eval(sprintf('vs.%s.SlipLawParameters.d_c1(2)',vs_names{k}));
    end
end
