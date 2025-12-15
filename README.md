# 论文复现报告：Machine Learning and Fund Characteristics Help to Select Mutual Funds with Positive Alpha

## 引言

本报告是对论文《Machine Learning and Fund Characteristics Help to Select Mutual Funds with Positive Alpha》的复现总结。该论文探讨了使用机器学习方法结合基金特征来选择具有正阿尔法的共同基金。复现项目旨在验证论文中的结果。

## 数据描述

复现使用的数据包括：

- **基金回报和规模**：来自CRSP的月度基金回报和总净资产，作者已**添加噪声**以保护数据专有性。
- **基金特征**：年度化基金特征，已根据论文第2.3节进行转换。
- **因子数据**：Fama-French五因子模型、动量因子和流动性因子。
- **其他数据**：通胀数据、NBER扩张/衰退指标、情绪指标等。

数据文件位于`data_sets/`文件夹中，包括Rdata、CSV、TXT和DTA格式。

## 方法

论文比较了多种方法来预测基金阿尔法：

- **机器学习方法**：梯度提升（Gradient Boosting）、随机森林（Random Forest）、弹性网络（Elastic Net）。
- **传统方法**：OLS回归。
- **基准方法**：等权重（Equally Weighted）和资产权重（Asset Weighted）。

代码分为几个文件夹：

- `code_for_ML_methods/`：实现机器学习方法的Rmd文件。
- `code_for_AW_method/` 和 `code_for_EW_method/`：资产权重和等权重方法的代码。
- Table 3-7 和 Figure 2-11文件夹用于生成

运行要求：推荐使用32GB RAM和Intel i7处理器。ML方法代码运行时间约24小时（使用6核并行）。

## 结果

复现生成了论文中的所有表格和图形。以下是关键结果摘要：

### 图2：SHAP值排序特征重要性

![image-20251215213902494](https://gitee.com/liukangliang/typora/raw/master/img/20251215213907.png)

对于弹性网络和OLS，特征重要性在最重要的两个特征之后迅速下降，而在非线性方法中，特征重要性的下降则更为平缓，约有七个特征几乎同等重要；而在梯度提升和随机森林这两种非线性方法中，value added、Alpha的t-统计值、市场Beta t-统计值和R²是排名前五的重要特征。

### 图3: 梯度提升中基金特征与业绩的非线性

![image-20251215210840748](https://gitee.com/liukangliang/typora/raw/master/img/20251215210844.png)

### 图4: 随机森林中基金特征与业绩的非线性

![image-20251215210959361](https://gitee.com/liukangliang/typora/raw/master/img/20251215211002.png)

在两种非线性方法中：Alpha的t-统计值与其条件均值SHAP值之间存在大致线性的。其他三个特征与未来业绩之间存在显著的非线性关系，基金主动程度与未来业绩之间的关系高度非线性，对于最活跃的基金而言，这种关系强烈正向，但对于其他基金则较为平坦。

### 图5：30个最重要交互作用的强度分布

![image-20251215214141190](https://gitee.com/liukangliang/typora/raw/master/img/20251215214145.png)

阿尔法t统计量、增加值（历史业绩）与市场贝塔t统计量、R²（活跃度）可能存在的四种交互作用中，有三种处于前30名之列。这说明，基金过去业绩预测未来业绩的能力可能取决于基金的活跃度。

### 图6：梯度提升模型中历史表现与基金活跃度指标的交互作用

![image-20251215211319406](https://gitee.com/liukangliang/typora/raw/master/img/20251215211322.png)

### 图7：随机森林模型中历史表现与基金活跃度指标的交互作用

![image-20251215211420017](https://gitee.com/liukangliang/typora/raw/master/img/20251215211423.png)

为了验证基金过去业绩预测未来业绩的能力取决于基金活跃度的猜想是否正确，我们针对每组交互变量，我们将所有观测值按基金活跃度特征划分为十个等分区间，并展示每个区间的条件均值SHAP值对历史绩效特征的影响。例如在图6中，当市场贝塔t统计量每增加十分位时，SHAP值都会随着alpha截距t统计量的增大而上升，但这种增长在贝塔t统计量较低十分位时更为显著（蓝色实线），因此对于高活跃基金过去的超额收益更能反映经理的真实能力。这与论文结果一致。

### 图8：梯度提升特征重要性的时间演变

![image-20251215214309212](https://gitee.com/liukangliang/typora/raw/master/img/20251215214312.png)

### 图9：随机森林特征重要性的时间演变

![image-20251215214339121](https://gitee.com/liukangliang/typora/raw/master/img/20251215214342.png)

我们进一步检验了在样本外期间每年中每个预测因子的重要性随时间的演变，发现Alpha（intercept t-stat）和Value Added自2000年起持续保持高重要性Market beta t-stat稳居前三，说明市场风险暴露仍是判断基金价值的关键维度经理年龄、流动性、管理年限等特征在整个时间段内几乎无重要性。

## 结论

尽管数据被作者加了噪声，但是复现结果仍然支持了论文的主要发现：机器学习方法可以有效利用基金特征来选择具有正阿尔法的基金。

- 机器学习方法能显著提升基金筛选能力，构建出净成本后仍具正α的主动组合
- 非线性算法（Gradient Boosting, Random Forest）表现最优；年化净α约2.5%，为平均管理费率的两倍以上
- 线性方法（OLS, Elastic Net）表现有限，说明绩效预测确实存在非线性
- 基金特征的预测力随时间变化，机器学习可通过动态再训练捕捉这种变化
- 整体结论：投资者可以从主动基金中获益，但前提是能使用复杂预测模型

## 运行指南

1. 安装R、Stata和MATLAB。
2. 运行`code_for_ML_methods/`以及AW和EW版本的代码
3. 依次运行其他文件夹中的代码生成表格和图形。



