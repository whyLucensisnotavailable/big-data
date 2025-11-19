% Figure 3: SHAP-style Dependence plots using SHAP values for Gradient Boosting
clear

% 获取当前脚本所在路径
currentFolder = fileparts(mfilename('fullpath'));

% 读取数据（使用相对路径）
Tchar = readtable(fullfile(currentFolder, '../data_sets/characteristics.txt'), 'Delimiter', ',');
Tshap = readtable(fullfile(currentFolder, '../data_sets/shap_values_GB.txt'), 'Delimiter', ',');

% 修正特征列名
Tchar.Properties.VariableNames{2}  = 'alpha intercept t-stat';
Tchar.Properties.VariableNames{10} = 'value added';
Tchar.Properties.VariableNames{11} = 'market beta t-stat';
Tchar.Properties.VariableNames{17} = 'R-squared';

Datachar  = table2array(Tchar);
Datashap  = table2array(Tshap);
Datachar  = Datachar(:, 2:end);

% 要绘制的特征索引
characteristics = [2, 10, 11, 17];

% 输出文件夹（与脚本同级）
outputFolder = fullfile(currentFolder, 'SHAP_Figures');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% 主循环
for char_ind = 1:length(characteristics)

    % 当前特征索引
    var = characteristics(char_ind);

    % x, y 数据
    x = Datachar(:, var);
    y = Datashap(:, var);

    % 取变量名并确保为字符型（修复你遇到的 cell 问题）
    varname = Tchar.Properties.VariableNames{var};
    if iscell(varname)
        varname_str = char(varname{1});
    else
        varname_str = char(varname);
    end

    % 去除极端值比例
    if var == 2
        q = 1; % alpha intercept t-stat 
    elseif var == 17
        q = 2.5; % R2
    elseif var == 10
        q = 10; % value added
    elseif var == 11
        q = 0.5; % market beta t-stat
    else
        q = 2;
    end

    pmin = prctile(x, q);
    pmax = prctile(x, 100 - q);

    % 分箱数量与步长
    nbins = 30;
    h = (pmax - pmin) / nbins;
    x_new = pmin + h/2 : h : pmax;

    % 计算每个 bin 的均值 SHAP（y_hat）
    y_hat = nan(length(x_new), 1);
    for i = 1:length(x_new)
        idx = x >= x_new(i) - h/2 & x <= x_new(i) + h/2;
        if sum(idx) > 0
            y_hat(i) = sum(y(idx)) / sum(idx);
        else
            y_hat(i) = NaN;
        end
    end

    % 绘图（SHAP 风格）
    graph = figure('Position', [100 100 1800 1335], 'Color', 'w');

    % 透明散点（颜色可调整）
    scatter(x, y, 18, 'filled', ...
        'MarkerFaceAlpha', 0.35, ...
        'MarkerFaceColor', [0.13 0.55 0.78], ...
        'MarkerEdgeColor', 'none');
    hold on

    % 平滑线（删除 NaN）
    valid = ~isnan(y_hat);
    plot(x_new(valid), y_hat(valid), 'LineWidth', 3.2, 'Color', [0.11 0.45 0.30]);

    % 小圆点标注（可选）——注释掉以保持简洁
    % plot(x_new(valid), y_hat(valid), 'o', 'MarkerSize', 4, 'MarkerFaceColor', [0.11 0.45 0.30], 'MarkerEdgeColor','none');

    hold off

    % 标题与标签（使用已经转换的 varname_str）
    title_str = sprintf('SHAP Dependence — %s', varname_str);
    title(title_str, 'FontSize', 22, 'FontWeight', 'bold', 'Color', [0.12 0.12 0.12]);
    xlabel(varname_str, 'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);
    ylabel('SHAP values', 'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);

    % 轴与网格样式
    ax = gca;
    ax.FontSize = 16;
    ax.FontName = 'Helvetica';
    ax.LineWidth = 1;
    ax.Box = 'off';
    ax.Color = 'w';
    ax.GridColor = [0.85 0.85 0.85];
    ax.GridAlpha = 0.45;
    ax.XColor = [0.2 0.2 0.2];
    ax.YColor = [0.2 0.2 0.2];
    grid on

    % 小幅调整坐标范围以美观（保留你原来的设置）
    if var == 2
        xlim([pmin - h, pmax + h]);
        ylim([-0.1 0.05]);
    elseif var == 10
        xlim([-0.2 0.2]);
        ylim([-0.035 0.035]);
    elseif var == 11
        xlim([-2 5]);
        ylim([-0.1 0.15]);
    elseif var == 17
        xlim([-3.5 1]);
        ylim([-0.09 0.09]);
    end

    % 设置输出尺寸与保存（PNG, 300 dpi）
    set(graph, 'Units', 'Inches');
    pos = get(graph, 'Position');
    set(graph, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

    % 清理文件名中的特殊字符
    safeName = regexprep(varname_str, '[^a-zA-Z0-9]', '_');
    pngName = fullfile(outputFolder, sprintf('Figure3_%s_GB.png', safeName));

    % 保存
    print(graph, pngName, '-dpng', '-r300');
    close(graph);

    fprintf('✅ Saved SHAP-style figure: %s\n', pngName);
end

disp('✅ All SHAP dependence plots saved as PNG files successfully!');
