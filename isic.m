% This file is to calculate the ISIC classification name

%% Load data
process = readtable('process.xlsx');
sheetName = 'activity overview'; % Replace with the name of the sheet you want to load

% Load the data from the specified sheet
tbl = readtable('activity_overview_for_users_3.1_default.xlsx', 'Sheet', sheetName);

activityname = string(tbl.activityName);
geo = string(tbl.geography);
productname = string(tbl.productName);
isicall =string(tbl.ISICClassificationNumber);
isicall=str2double(isicall);
processname=process.name;
isicclass_name = string(tbl.ISICClassificationName);

%% match the isic name with our preprocessed data
isicnumber=[];
for i = 1:2546
    str1 = string(processname(i,1));
    for j = 1:11332
        a = productname(j,1);
        b = geo(j,1);
        c = activityname(j,1);
        str2 =  append(a, '//[', b, '] ', c);
        if strcmp(str1, str2)
            isicnumber(end+1) = isicall(j,1);
        end
    end
end


%% Calculate the frequency of each isic and sort them

% Calculate the frequency of each unique value
uniqueValues = unique(isicnumber);
valueCounts = zeros(size(uniqueValues));

for i = 1:length(uniqueValues)
    valueCounts(i) = sum(isicnumber == uniqueValues(i));
end

% Sort the unique values by frequency in descending order
[sortedCounts, sortedIndices] = sort(valueCounts, 'descend');
sortedValues = uniqueValues(sortedIndices);
%% Find the top 10 percentile isic
% Calculate the top 10 percentile threshold
percentile = 95;
threshold = prctile(sortedCounts, percentile);

% Select isic index with counts above the threshold
selectedInd = sortedValues(sortedCounts > threshold);
selectedCounts = sortedCounts(sortedCounts > threshold);

% Find the corresponding name of each index
isic_name=strings(1, length(selectedInd));
for i = 1:length(selectedInd)
    b=find(isicall==selectedInd(1,i));
    b=b(1);
    isic_name(i) = isicclass_name(b);
end

%% Create a bar graph of isic

% Reset the color map to default
colormap('default');

% Create a bar graph with custom colors
bar(selectedCounts, 'FaceColor', 'flat');

% Set the axis labels
xticks(1:14);
xticklabels(isic_name);
xtickangle(45);

% Label the axes and title
xlabel('ISIC classification name')
ylabel('Process counts');
title('# of processes per ISIC classification (only top 5 percentile of all data shown here)', 'FontSize', 12, 'Units', 'normalized', 'Position', [0.5, 1.04]);
for i = 1:numel(selectedCounts)
    text(i, selectedCounts(i), num2str(selectedCounts(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end

% Set custom colors for individual bars
colormap(customColors);