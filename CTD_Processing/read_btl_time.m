function BTL = read_btl_time(filename)
% READ_BTL_TIME Reads a Seabird .btl file and returns data as a MATLAB table with datetime.
%
%   BTL = READ_BTL_TIME(filename)
%
%   Inputs:
%       filename - Path to the .btl file
%
%   Outputs:
%       BTL - MATLAB table containing bottle data with a combined datetime variable if Date/Time columns exist.

    % Open and read the file as text
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    raw = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
    fclose(fid);
    raw = raw{1};

    % Find header end line
    endLine = find(contains(raw, '*END*'), 1);
    if isempty(endLine)
        error('Could not find *END* marker in file.');
    end

    % Extract column names
    colLines = raw(contains(raw, '# name'));
    nCols = numel(colLines);
    colNames = cell(nCols,1);
    for i = 1:nCols
        parts = strsplit(colLines{i}, '=');
        if numel(parts) >= 2
            colName = strtrim(parts{2});
            colName = matlab.lang.makeValidName(colName);
            colNames{i} = colName;
        else
            colNames{i} = sprintf('Var%d',i);
        end
    end

    % Read data lines
    dataLines = raw(endLine+1:end);
    if isempty(dataLines)
        warning('No data rows found in this file.');
        BTL = table();
        return;
    end

    % Convert lines to cell arrays
    dataCells = cellfun(@(x) strsplit(strtrim(x)), dataLines, 'UniformOutput', false);
    maxCols = max(cellfun(@numel, dataCells));
    for i = 1:numel(dataCells)
        if numel(dataCells{i}) < maxCols
            dataCells{i}(end+1:maxCols) = {''};
        end
    end
    dataMat = vertcat(dataCells{:});

    % Try to convert to numeric where possible
    data = cell(size(dataMat));
    for j = 1:maxCols
        numCol = str2double(dataMat(:,j));
        if all(isnan(numCol) & ~cellfun(@isempty,dataMat(:,j)))
            data(:,j) = dataMat(:,j); % keep as text
        else
            data(:,j) = num2cell(numCol);
        end
    end

    % Ensure enough column names
    if length(colNames) < maxCols
        for k = (length(colNames)+1):maxCols
            colNames{k} = sprintf('Var%d',k);
        end
    end

    % Create table
    BTL = cell2table(data, 'VariableNames', colNames(1:maxCols));

    % --- Handle Date and Time columns ---
    dateIdx = find(contains(colNames,'Date','IgnoreCase',true), 1);
    timeIdx = find(contains(colNames,'Time','IgnoreCase',true), 1);
    if ~isempty(dateIdx) && ~isempty(timeIdx)
        try
            dateStr = BTL.(colNames{dateIdx});
            timeStr = BTL.(colNames{timeIdx});
            if iscell(dateStr) && iscell(timeStr)
                combinedStr = strcat(dateStr, {' '}, timeStr);
                % Try multiple formats
                try
                    BTL.DateTime = datetime(combinedStr, 'InputFormat','yyyy-MM-dd HH:mm:ss', 'TimeZone','UTC');
                catch
                    BTL.DateTime = datetime(combinedStr, 'InputFormat','dd-MMM-yyyy HH:mm:ss', 'TimeZone','UTC');
                end
            end
        catch
            warning('Failed to convert Date and Time columns to datetime.');
        end
    end
end
