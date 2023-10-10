% This file is to calculate the flow frequency
%% Load data
% This data set cannot be made public. If you need to access, please contact the authors.
load("eco_old_original.mat")

ecodataoriginal( ~any(ecodataoriginal,2), : ) = [];% clean the row with no data
ecodataoriginal(  :, ~any(ecodataoriginal,1)) = [];% clean the column with no data
data = ecodataoriginal.';
[m,n]=size(data); % process*flow


% use data's structure to calculate frequency
data_str = (data~=0);
H_1 = data_str.'; % missing flow * process

%% plot frequency
plot(sum(H_1,2))
title("Flow frequency",'FontSize', 22);
xlabel('Flow index','FontSize', 20);
ylabel('Apperance counts','FontSize', 20);
xlim([0, 7029]);
set(gca, 'FontSize', 18); % Adjust FontSize as needed for both x and y ticks

%% Get the top 5 flows
a = sum(H_1,2);
[sorted_values, sorted_indices] = sort(a, 'descend');
top_5_values = sorted_values(1:5);
top_5_indices = sorted_indices(1:5);

flowname=flow.name;
top_5_flowname = flowname(top_5_indices,1);


%% Plot the top 5 flows with its names and values
bar(top_5_values);
box off;
yticks(0:1000:1000);
set(gca, 'FontSize', 12);
for i = 1:numel(top_5_values)
    text(i, top_5_values(i), num2str(top_5_values(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end

% Set the axis labels and title
xticks(1:5);
xticklabels(string(top_5_flowname));
xtickangle(45);
title("Top 5 flow frequency")
% Adjust the font size
set(gca, 'FontSize', 12);
% Hide y-axis ticks
set(gca, 'YTickLabel', []);




