% This file is to calculate the flow magnitude
%% Load data
% This data set cannot be made public. If you need to access, please contact the authors.
load("eco_old_original.mat")

ecodataoriginal( ~any(ecodataoriginal,2), : ) = [];% clean the row with no data
ecodataoriginal(  :, ~any(ecodataoriginal,1)) = [];% clean the column with no data
data = ecodataoriginal.';
[m,n]=size(data); % process*flow

%% Plot the flow magnitude
%find the maximum value in each flow
a = max(data);
% plot the maximum value in each flow with the flow index
plot(a)
ylabel('Magnitude','FontSize', 20);
xlabel('Flow index','FontSize', 20);
%title('Flow magnitude','FontSize', 22);
xlim([0, 7029]);
% Enlarge the size of xtick and ytick labels
set(gca, 'FontSize', 18); % Adjust FontSize as needed for both x and y ticks

%% Plot the top 2 flows's magnitude and the last 2 non-zero flow magnitude

% load flows' name
flowname = string(flow.name);

% Find the indices of the top 2 and last 2 non-zero values
sorted_data = sort(a(a > 0), 'descend'); % Sort non-zero values in descending order
top_2_values = sorted_data(1:2);
last_2_values = sorted_data(end-1:end);

% Find the corresponding flow indices for the top 2 non-zero values
top_2_indices = find(a == top_2_values(1) | a == top_2_values(2));

% Find the corresponding flow indices for the last 2 non-zero values
last_2_indices = find(a == last_2_values(1) | a == last_2_values(2));

% Extract the top 2 and last 2 flow names
top_1_flowname = flowname(top_2_indices(1));
top_2_flowname = flowname(top_2_indices(2));
last_1_flowname = flowname(last_2_indices(1));
last_2_flowname = flowname(last_2_indices(2));

% Create a bar graph with the selected values and adjust BarWidth and BarSpacing
bar([top_2_values, NaN, last_2_values]);
box off;

% Add annotations above each bar
% Modify the annotations to replace NaN with "......"
annotations = [top_2_values, NaN, last_2_values];
for i = 1:numel(annotations)
    if ~isnan(annotations(i))
        text(i, annotations(i), num2str(annotations(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','FontSize', 16)
    end
end

% Set the title and axis labels
title('Top 2 and Last 2 Flow Magnitude', 'FontSize', 18);
% Narrow the space between the y-axis and the first bar
xlim([0.5, 5.5]);
set(gca, 'FontSize', 12); % Adjust FontSize as needed
% Hide y-axis ticks
set(gca, 'YTickLabel', []);
set(gca, 'xTickLabel', []);