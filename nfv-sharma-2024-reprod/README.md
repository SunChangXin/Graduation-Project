1. 创建环境
conda env create -f environment.yml
conda activate nfv-sharma-2024

2. 跑实验
python runners/run_fig7a_slo.py         # SLO百分位→延迟（Fig.7a 趋势）
python runners/run_fig7b_sfc_len.py     # SFC长度→延迟（Fig.7b 趋势）
python runners/run_fig7c_cross.py       # 交叉流→延迟（Fig.7c 趋势）
python runners/run_fig8_realize.py      # 可实现性判定计时（Fig.8 趋势）

# 说明：为了可跑与简洁，我在 snc_math.py 里用了工程近似（例如把 MMPP 等效到 (σ,ρ)，
# 用 Chernoff 模板 + θ 搜索、Boole 分配 ε）。这些近似足以复现论文图的主要趋势与拐点：
· SLO 越严（分位越高）→ 延迟上界升高；
· SFC 越长→ 延迟非线性上升，超阈后陡增；
· 交叉流越多→ 延迟加速增长（>8 出现“跳升”）；
· 判定时间随SFC长度主导增长，DC规模影响较弱。

# 若你要进一步“收紧上界”，可把 mgf_mmpp4 换成矩阵指数精确形式、在 load_balance_scaling.py 
# 中把 X/Y 按论文式(2) 做 log-MGF 复合，即可更接近原文数值。