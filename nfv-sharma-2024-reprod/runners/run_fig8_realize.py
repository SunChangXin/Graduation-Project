# runners/run_fig8_realize.py
#
# 分析不同 数据中心规模（DC size） 和 服务功能链长度（SFC length） 对实现时间的影响
# 需要结合实际数据进行DAG生成计时
#

import yaml, numpy as np
from src.realize_checker import realize_time_benchmark
import sys
from pathlib import Path

# --- 定位工程根目录（repo_root = nfv-sharma-2024-reprod/） ---
THIS_FILE = Path(__file__).resolve()
REPO_ROOT = THIS_FILE.parents[1]   # .../nfv-sharma-2024-reprod
CONFIGS_DIR = REPO_ROOT / "configs"

# 确保可以 import 顶层包 src.*
sys.path.insert(0, str(REPO_ROOT))

# cfg = yaml.safe_load(open(CONFIGS_DIR / "experiment_realize.yaml"))
cfg = yaml.safe_load(open(CONFIGS_DIR / "experiment_realize.yaml", encoding="utf-8"))


print("servers,sfc_len,prebuild,build_s,verify_s")
for s in cfg["dc_sizes_servers"]:
    for L in cfg["sfc_length_candidates"]:
        b,v = realize_time_benchmark(dc_servers=s, sfc_len=L, pvr=cfg["pvr"], prebuild=cfg["prebuild_dags"])
        print(f"{s},{L},{cfg['prebuild_dags']},{b:.3f},{v:.3f}")
