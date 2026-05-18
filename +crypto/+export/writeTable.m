function outputPath = writeTable(data, outputPath)
%WRITETABLE Export a MATLAB table to CSV or XLSX.
    arguments
        data table
        outputPath (1,1) string
    end

    [folder, ~, ext] = fileparts(outputPath);
    if strlength(folder) > 0 && ~isfolder(folder)
        mkdir(folder);
    end

    switch lower(ext)
        case ".csv"
            writetable(data, outputPath);
        case {".xlsx", ".xls"}
            writetable(data, outputPath, "FileType", "spreadsheet");
        otherwise
            error("crypto:export:UnsupportedExtension", "Use .csv, .xlsx, or .xls for table export.");
    end
end
