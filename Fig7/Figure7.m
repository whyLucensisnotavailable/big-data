% Figure 7: Dependence plots using SHAP values for Random Forests
% INTERACTION EFFECTS
clear; close all;

% === 读取数据 ===
% 使用相对路径
Tchar = readtable('../data_sets/characteristics.txt', 'Delimiter', ',');
Tshap = readtable('../data_sets/shap_values_GB.txt', 'Delimiter', ',');
% === 重命名列名 ===
Tchar.Properties.VariableNames{2}  = 'alpha intercept t-stat';
Tchar.Properties.VariableNames{10} = 'value added';
Tchar.Properties.VariableNames{11} = 'market beta t-stat';
Tchar.Properties.VariableNames{17} = 'R-squared';

% === 特征索引 ===
characteristicsx = [2 10];  % X轴变量
characteristicsz = [11 17]; % 交互变量
varNames = Tchar.Properties.VariableNames;

% === 输出文件夹 ===
outputFolder = fullfile(pwd, 'figures_RF_interaction');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% === 主循环 ===
for char_indx = 1:2
    varx = characteristicsx(char_indx);
    for char_indz = 1:2
        varz = characteristicsz(char_indz);

        Datachar = table2array(Tchar);
        Datashap = table2array(Tshap);
        Datachar = Datachar(:, 2:end);

        x = Datachar(:, varx);
        z = Datachar(:, varz);
        y = Datashap(:, varx);

        varnamex = varNames{varx};
        varnamez = varNames{varz};

        % === Tail 处理 ===
        if varx == 2
            qx = 1;
        elseif varx == 17
            qx = 2.5;
        elseif varx == 10
            qx = 10;
        elseif varx == 11
            qx = 0.5;
        end

        pminx = prctile(x, qx);
        pmaxx = prctile(x, 100 - qx);

        % === 分箱设置 ===
        nx = 30;
        hx = (pmaxx - pminx) / nx;
        x_new = pminx + hx/2 : hx : pmaxx;

        % === Z 分位数 ===
        qz = 0:10:100;
        pz = zeros(size(qz));
        for j = 1:length(qz)
            pz(j) = prctile(z, qz(j));
        end

        % === 计算平均 SHAP ===
        y_hat = zeros(length(x_new), length(pz) - 1);
        for i = 1:length(x_new)
            for k = 2:length(pz)
                idx = x >= x_new(i) - hx/2 & x <= x_new(i) + hx/2 & ...
                      z >= pz(k-1) & z <= pz(k);
                y_hat(i, k-1) = sum(y(idx)) / sum(idx);
            end
        end

        % === 绘图 ===
        graph = figure('Position', [100 100 1800 1335]);

        % 散点（蓝色半透明）
        scatter(x, y, 25, 'MarkerEdgeColor', [0.35 0.55 0.85], ...
            'MarkerFaceAlpha', 0.35, 'MarkerEdgeAlpha', 0.35);
        hold on;

        % 线条（蓝紫渐变）
        cmap = parula(length(qz) - 1);
        for line = 1:length(qz) - 1
            plot(x_new, y_hat(:, line), 'LineWidth', 2.5, ...
                'Color', cmap(line, :), ...
                'DisplayName', sprintf('Decile %d', line));
        end
        hold off;

        % === 美化 ===
        grid on; box on;
        xlabel(varnamex, 'FontSize', 22.5);
        ylabel('SHAP values', 'FontSize', 22.5);
        title(sprintf('Interaction: %s × %s', varnamex, varnamez), ...
              'FontSize', 24, 'FontWeight', 'bold');
        leg = legend('show', 'Location', 'south east');
        ax = gca; 
        ax.FontSize = 20;
        ax.FontName = 'Helvetica';

        % === 坐标范围与文件名 ===
        if varx == 2 && varz == 11
            xlim([pminx - hx, pmaxx + hx]); ylim([-0.1 0.05]);
            filename = 'Figure7_Interaction_alphaintercepttstat_marketbetatstat_RF.png';
        elseif varx == 2 && varz == 17
            xlim([pminx - hx, pmaxx + hx]); ylim([-0.1 0.05]);
            filename = 'Figure7_Interaction_alphaintercepttstat_R2_RF.png';
        elseif varx == 10 && varz == 11
            xlim([-0.2 0.2]); ylim([-0.035 0.035]);
            filename = 'Figure7_Interaction_valueadded_marketbetatstat_RF.png';
        elseif varx == 10 && varz == 17
            xlim([-0.2 0.2]); ylim([-0.035 0.035]);
            filename = 'Figure7_Interaction_valueadded_R2_RF.png';
        end

        % === 保存 PNG ===
        saveas(graph, fullfile(outputFolder, filename));
        close(graph);
    end
end
