function [file_df] = readUCSCtriax(file_name)
    opts = detectImportOptions(file_name,'NumHeaderLines', 33);
    opts.DataLines = 36; % hm
    opts.VariableNamesLine = 34;
    file_df = readtable(file_name, opts);
    file_df.OG_Index = [1:length(file_df.Time)]';