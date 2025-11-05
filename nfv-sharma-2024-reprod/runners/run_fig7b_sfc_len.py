# runners/run_fig7b_sfc_len.py
#
# 分析 SFC 长度 对 延迟 的影响，并为每个 SFC 长度输出延迟结果。通过实验，可以观察到 SFC 长度对延迟的影响趋势，
# 通常来说，SFC 长度越长，延迟越大
#

import yaml, numpy as np
from src.delay_on_dag import dag_path_delay_mmpp
import sys
from pathlib import Path

# --- 定位工程根目录（repo_root = nfv-sharma-2024-reprod/） ---
THIS_FILE = Path(__file__).resolve()
REPO_ROOT = THIS_FILE.parents[1]   # .../nfv-sharma-2024-reprod
CONFIGS_DIR = REPO_ROOT / "configs"

# 确保可以 import 顶层包 src.*
sys.path.insert(0, str(REPO_ROOT))

cfg = yaml.safe_load(open(CONFIGS_DIR / "experiment_sfc_len.yaml"))
# 读取 MMPP 配置（相对路径转成绝对路径）
mmpp_cfg_path = (CONFIGS_DIR / cfg["mmpp_config"]).resolve()
mmpp = yaml.safe_load(open(mmpp_cfg_path, "r", encoding="utf-8"))

rates = mmpp["rate_sets_pps"][0]
pkt = mmpp["packet_size_bytes"]
theta_grid = (mmpp["theta_search"]["min"], mmpp["theta_search"]["max"], mmpp["theta_search"]["steps"])
eps = 1.0 - cfg["percentile"]
C_bps = cfg["server_line_rate_gbps"] * 1e9

print("SFC_len, delay_ms")
for L in cfg["sfc_lengths"]:
    d = dag_path_delay_mmpp(list(range(L)), rates, pkt, C_bps, eps, theta_grid)
    print(f"{L}, {d*1000:.3f}")
