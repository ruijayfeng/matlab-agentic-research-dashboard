function data = readTable(inputPath)
%READTABLE Read a CSV/XLSX table from disk.
    arguments
        inputPath (1,1) string
    end

    if ~isfile(inputPath)
        error("crypto:export:FileMissing", "File does not exist: %s", inputPath);
    end

    [~, ~, ext] = fileparts(inputPath);
    switch lower(ext)
        case ".csv"
            data = readtable(inputPath, "TextType", "string");
        case {".xlsx", ".xls"}
            data = readtable(inputPath, "TextType", "string");
        otherwise
            error("crypto:export:UnsupportedExtension", "Use .csv, .xlsx, or .xls for table import.");
    end
end
