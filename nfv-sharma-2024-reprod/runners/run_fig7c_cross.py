# runners/run_fig7c_cross.py
#
# 分析 交叉流数目 对 网络延迟 的影响，并为每个交叉流数目输出延迟结果。通过实验，可以观察到交叉流数目对延迟的影响趋势，
# 通常来说，交叉流数目越多，延迟越高。
#

import yaml, numpy as np
from src.snc_math import approx_sigma_rho_from_mmpp, e2e_delay_concat
import sys
from pathlib import Path

# --- 定位工程根目录（repo_root = nfv-sharma-2024-reprod/） ---
THIS_FILE = Path(__file__).resolve()
REPO_ROOT = THIS_FILE.parents[1]   # .../nfv-sharma-2024-reprod
CONFIGS_DIR = REPO_ROOT / "configs"

# 确保可以 import 顶层包 src.*
sys.path.insert(0, str(REPO_ROOT))

cfg = yaml.safe_load(open(CONFIGS_DIR / "experiment_crossflows.yaml"))
# 读取 MMPP 配置（相对路径转成绝对路径）
mmpp_cfg_path = (CONFIGS_DIR / cfg["mmpp_config"]).resolve()
mmpp = yaml.safe_load(open(mmpp_cfg_path, "r", encoding="utf-8"))

rates = mmpp["rate_sets_pps"][0]
pkt = mmpp["packet_size_bytes"]
theta_grid = (mmpp["theta_search"]["min"], mmpp["theta_search"]["max"], mmpp["theta_search"]["steps"])
eps = 1.0 - cfg["percentile"]
C_bps = cfg["server_line_rate_gbps"] * 1e9

sigma, rho = approx_sigma_rho_from_mmpp(rates, pkt)

print("cross_flows, delay_ms")
for cf in cfg["cross_flows_list"]:
    # 简化：每跳 leftover C' = C - cf*rho，串联4跳
    hops = []
    for _ in range(cfg["sfc_length"]):
        C_eff = max(1e6, C_bps - cf * rho)  # 不允许非正
        hops.append({"rho_bps": rho, "sigma_bits": sigma, "C_bps": C_eff})
    d = e2e_delay_concat(hops, eps_total=eps, theta_grid=theta_grid)
    print(f"{cf}, {d*1000:.3f}")
