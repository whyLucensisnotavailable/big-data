% Figure 4: Dependence plots using SHAP values for Random Forests
clear; close all;

% === 读取数据 ===
% 使用相对路径
Tchar = readtable('../data_sets/characteristics.txt', 'Delimiter', ',');
Tshap = readtable('../data_sets/shap_values_GB.txt', 'Delimiter', ',');

% === 重命名列名 ===
Tchar.Properties.VariableNames{2} = 'alpha intercept t-stat';
Tchar.Properties.VariableNames{10} = 'value added';
Tchar.Properties.VariableNames{11} = 'market beta t-stat';
Tchar.Properties.VariableNames{17} = 'R-squared';

Datachar = table2array(Tchar);
Datashap = table2array(Tshap);
Datachar = Datachar(:,2:end);

% === 要绘制的特征索引 ===
characteristics = [2 10 11 17];
varNames = Tchar.Properties.VariableNames;

% === 输出文件夹（当前路径下的 figures_RF）===
outputFolder = fullfile(pwd, 'figures_RF');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% === 循环绘制每个特征 ===
for char_ind = 1:4
    var = characteristics(char_ind);
    varname = varNames{var};

    x = Datachar(:, var);
    y = Datashap(:, var);

    % --- Tail 剔除 ---
    if var == 2
        q = 1;
    elseif var == 17
        q = 2.5;
    elseif var == 10
        q = 10;
    elseif var == 11
        q = 0.5;
    end

    pmin = prctile(x, q);
    pmax = prctile(x, 100 - q);

    % --- 平滑拟合 ---
    n = 30;
    h = (pmax - pmin) / n;
    x_new = pmin + h/2 : h : pmax;
    y_hat = zeros(length(x_new), 1);

    for i = 1:length(x_new)
        idx = x >= x_new(i) - h/2 & x <= x_new(i) + h/2;
        y_hat(i) = sum(y(idx)) / sum(idx);
    end

    % === 绘图 ===
    graph = figure('Position', [100 100 1800 1335]);

    % 使用蓝色半透明散点 + 深蓝线
    scatter(x, y, 25, 'MarkerEdgeColor', [0.35 0.55 0.85], ...
        'MarkerFaceAlpha', 0.35, 'MarkerEdgeAlpha', 0.35);
    hold on;
    plot(x_new, y_hat, 'LineWidth', 3, 'Color', [0.05 0.15 0.55]);
    hold off;

    % === 图形美化 ===
    grid on;
    box on;
    xlabel(varname, 'FontSize', 22.5);
    ylabel('SHAP values', 'FontSize', 22.5);
    title(sprintf('SHAP Dependence — %s', varname), ...
        'FontSize', 24, 'FontWeight', 'bold');
    ax = gca;
    ax.FontSize = 20;

    % === 各特征的坐标范围 ===
    if var == 2
        xlim([pmin - h, pmax + h]);
        ylim([-0.1 0.05]);
        filename = 'Figure4_alphaintercepttstat_RF.png';
    elseif var == 10
        xlim([-0.2 0.2]);
        ylim([-0.035 0.035]);
        filename = 'Figure4_valueadded_RF.png';
    elseif var == 11
        xlim([-2 5]);
        ylim([-0.1 0.15]);
        filename = 'Figure4_marketbetatstat_RF.png';
    elseif var == 17
        xlim([-3.5 1]);
        ylim([-0.09 0.09]);
        filename = 'Figure4_R2_RF.png';
    end

    % === 保存为 PNG ===
    saveas(graph, fullfile(outputFolder, filename));

    close(graph);
end
