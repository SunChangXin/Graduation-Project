# runners/run_fig7a_slo.py
#
# 通过 Monte Carlo 仿真 来探究不同 SLO 分位数下的延迟变化，并为不同的流量模式输出对应的延迟统计数据，
# 最终画出 SLO → 延迟 的曲线趋势图
#

import yaml, numpy as np, random
from pathlib import Path
import sys
import argparse

# --- 定位工程根目录（repo_root = nfv-sharma-2024-reprod/） ---
THIS_FILE = Path(__file__).resolve()
REPO_ROOT = THIS_FILE.parents[1]   # .../nfv-sharma-2024-reprod
CONFIGS_DIR = REPO_ROOT / "configs"

# 确保可以 import 顶层包 src.*
sys.path.insert(0, str(REPO_ROOT))

# 函数在 delay_on_dag.py 中
from src.delay_on_dag import dag_path_delay_mmpp

def main(cfg_path: Path):
    # 读取主配置
    cfg = yaml.safe_load(open(cfg_path, "r", encoding="utf-8"))
    # 读取 MMPP 配置（相对路径转成绝对路径）
    mmpp_cfg_path = (CONFIGS_DIR / cfg["mmpp_config"]).resolve()
    mmpp = yaml.safe_load(open(mmpp_cfg_path, "r", encoding="utf-8"))

    percentiles = cfg["percentiles"]
    random.seed(cfg["seed"]); np.random.seed(cfg["seed"])

    rates_sets = mmpp["rate_sets_pps"]
    pkt = mmpp["packet_size_bytes"]
    eps_list = [1.0 - p for p in percentiles]
    theta_grid = (
        mmpp["theta_search"]["min"],
        mmpp["theta_search"]["max"],
        mmpp["theta_search"]["steps"],
    )

    C_bps = cfg["server_line_rate_gbps"] * 1e9
    sfc_len = cfg["sfc_length"]
    trials = cfg["trials"]

    for rates in rates_sets:
        print(f"\nRate set={rates}")
        for eps in eps_list:
            ds = []
            for _ in range(trials):
                d = dag_path_delay_mmpp(
                    path_servers=list(range(sfc_len)),
                    rates_pps=rates,
                    pkt_bytes=pkt,
                    C_bps=C_bps,
                    eps=eps,
                    theta_grid=theta_grid,
                )
                ds.append(d * 1000)  # 转毫秒
            print(f"SLO p={1-eps:.6f}: mean={np.mean(ds):.3f} ms, p50={np.percentile(ds,50):.3f} ms")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config",
        type=str,
        default=str(CONFIGS_DIR / "experiment_slo.yaml"),
        help="配置文件路径（默认指向工程根目录下 configs/experiment_slo.yaml）",
    )
    args = parser.parse_args()
    cfg_path = Path(args.config).resolve()
    main(cfg_path)
