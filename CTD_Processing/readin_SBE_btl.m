function btlsum = readin_SBE_btl(filename)

    % Read and combine (avg) and (sdev) rows from a Sea-Bird .btl file
    % Author: ChatGPT (GPT-5)
    % Date: 2025-11-11
    raw = readlines(filename);
    
    % --- 1. Find where data starts ---
    headerIdx = find(contains(raw, 'Bottle'), 1);
    if isempty(headerIdx)
        error('No "Bottle" header line found in file.');
    end
    
    % Extract header line and clean it up
    headerLine = strtrim(raw(headerIdx));
    headers = strsplit(regexprep(headerLine, '\s+', ' '));
    
    % --- 2. Identify avg and sdev rows ---
    dataLines = raw(headerIdx+1:end);
    isAvg = contains(dataLines, '(avg)');
    isSdev = contains(dataLines, '(sdev)');
    
    avgLines0 = strtrim(dataLines(isAvg));
    avgLines = erase(avgLines0,'(avg)');
    sdevLines0 = strtrim(dataLines(isSdev));
    sdevLines = erase(sdevLines0,'(sdev)');

    splitData = cellfun(@(x) strsplit(strtrim(x)), cellstr(avgLines), 'UniformOutput', false);
    C = vertcat(splitData{:});
    dateStrings = string(strcat((C(:,2)), {' '}, (C(:,3)), {' '}, (C(:,4))));
    [~,m] = size(C);
    T_avg = table;
    for j = 1:m
        T_avg(:,j) = table(double(string(C(:,j))));
    end
    T_avg = removevars(T_avg,{'Var2','Var3','Var4'});
    Date = datetime(dateStrings, 'InputFormat', 'MMM dd yyyy');
    T_avg.Date = Date;
    T_avg = movevars(T_avg, 'Date', 'Before', 'Var5');
    headers = erase(headers,'/'); 
    T_avg.Properties.VariableNames = headers;

    splitDatasdev = cellfun(@(x) strsplit(strtrim(x)), cellstr(sdevLines), 'UniformOutput', false);
    C = vertcat(splitDatasdev{:});
    DateTime = datetime(strcat(dateStrings,' ', string(C(:,1))),'InputFormat','MMM dd yyyyHH:mm:ss');

    T_avg.Date = DateTime; 
    btlsum = T_avg;

end