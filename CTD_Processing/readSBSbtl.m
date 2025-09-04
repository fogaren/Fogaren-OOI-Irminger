function [data] = readSBSbtl ( filename )

    fid = fopen(filename, 'rt');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Search for header line
    headerLine = '';
    while ischar(headerLine)
        headerLine = fgetl(fid);
        if contains(headerLine, 'Bottle') && contains(headerLine, 'Latitude') && contains(headerLine, 'Longitude')
            break;
        end
    end

    % Clean and extract variable names
    headers = strsplit(strtrim(headerLine));
    headers = matlab.lang.makeValidName(headers);

    % Skip the next line (Position/Time labels)
    fgetl(fid);

    % Read alternating lines (avg only)
    avgData = [];
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if contains(line, '(avg)')
            numericLine = regexp(line, '[^\s()]+', 'match');
            % Remove 'avg' tag
            numericLine = numericLine(1:end-1);
            avgData(end+1, 1) = str2double(numericLine{1}); %#ok<AGROW>
            dummydate = [numericLine{2} ' ' double(numericLine{3}) ' ' numericLine{4}];
            dummydate = datetime(dummydate,'InputFormat','MMM dd yyyy');
            avgData(end,2) = datenum(dummydate);
            avgData(end,3:14) = [str2double(numericLine{5}) str2double(numericLine{6}) str2double(numericLine{7}) str2double(numericLine{8})...
                str2double(numericLine{9}) str2double(numericLine{10}) str2double(numericLine{11}) str2double(numericLine{12}) str2double(numericLine{13})...
                str2double(numericLine{14}) str2double(numericLine{15}) str2double(numericLine{16})];            
        end

    end

    fclose(fid);

    % Truncate header to match data columns (if necessary)
    nCols = size(avgData, 2);
    headers = headers(1:min(nCols, numel(headers)));

    % Return as table
    data = array2table(avgData(:, 1:numel(headers)), 'VariableNames', headers);
end
