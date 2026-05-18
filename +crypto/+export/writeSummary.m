function outputPath = writeSummary(summary, outputPath)
%WRITESUMMARY Export analysis summary text to a UTF-8 text file.
    arguments
        summary
        outputPath (1,1) string
    end

    [folder, ~, ~] = fileparts(outputPath);
    if strlength(folder) > 0 && ~isfolder(folder)
        mkdir(folder);
    end

    if isstruct(summary) && isfield(summary, "Text")
        text = string(summary.Text);
    else
        text = string(summary);
    end

    fid = fopen(outputPath, "w", "n", "UTF-8");
    if fid < 0
        error("crypto:export:OpenFailed", "Could not open %s for writing.", outputPath);
    end
    cleaner = onCleanup(@() fclose(fid));
    fprintf(fid, "%s\n", text);
    clear cleaner
end
