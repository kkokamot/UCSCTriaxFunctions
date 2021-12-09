function [file_df] = readUCSCtriax(file_name)
    opts = detectImportOptions(file_name,'NumHeaderLines', 33);
    opts.DataLines = 36;
    opts.VariableNamesLine = 34;
    file_df = readtable(file_name, opts);