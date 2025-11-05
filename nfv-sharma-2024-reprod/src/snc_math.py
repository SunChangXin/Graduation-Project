import numpy as np

# --------- 基础：到达与服务的 MGF/Effective Bandwidth ---------

def mgf_poisson(theta, rate_pps, pkt_bytes, t):
    # 泊松到达 A(t) 的MGF：E[e^{θA}] = exp( λ t ( e^{θ*L} - 1 ) )
    L = pkt_bytes * 8.0  # bits
    return np.exp(rate_pps * t * (np.exp(theta * L) - 1.0))

def mgf_mmpp4(theta, rates_pps, Q, pkt_bytes, t):
    """
    简化近似：用等效速率 lambda_eq = π · rates 代替（避免矩阵指数复杂度）
    若需更紧，可实现 matrix-exponential：exp( (Q + diag(r_i (e^{θL}-1))) t ) · 1
    """
    L = pkt_bytes * 8.0
    # 稳态分布 π 解 Q^T π = 0, sum π = 1
    Q = np.array(Q, dtype=float)
    A = Q.T.copy()
    A[-1,:] = 1.0
    b = np.zeros(Q.shape[0]); b[-1] = 1.0
    pi = np.linalg.lstsq(A, b, rcond=None)[0]
    lambda_eq = float(np.dot(pi, np.array(rates_pps)))
    return np.exp(lambda_eq * t * (np.exp(theta * L) - 1.0))

def service_curve_rate_latency(C_bps, latency_s, t):
    # 速率-延迟服务曲线 β(t) = C * max(0, t - T)
    return max(0.0, C_bps * max(0.0, t - latency_s))

# --------- Leftover Service (交叉流影响) 的保守处理 ---------

def leftover_service_rate(C_bps, rho_cross_bps):
    """
    简化 left-over：恒定速率服务器 - 交叉平均速率
    真实 SNC 可用 (σ,ρ) 或 MGF-based 的最小化形式；这里给稳健近似：
    """
    return max(0.0, C_bps - rho_cross_bps)

# --------- 单跳延迟上界（MGF-based θ 搜索的模板） ---------

def violation_bound_delay(theta, sigma_bits, rho_bps, C_bps, eps):
    """
    常见的 Chernoff 结构：P{W > d} <= exp(-theta*(C - rho)*d + theta*sigma) <= eps
    => d >= (theta*sigma - ln eps) / (theta*(C-rho))
    """
    denom = theta * max(1e-12, (C_bps - rho_bps))
    return (theta * sigma_bits - np.log(eps)) / denom

def single_hop_delay_bound(eps, rho_bps, sigma_bits, C_bps,
                           theta_min=1e-6, theta_max=0.1, steps=200):
    # --- 强制把可能由 YAML 读入的字符串转为数值 ---
    theta_min = float(theta_min)
    theta_max = float(theta_max)
    steps = int(steps)
    if steps < 2:
        steps = 2
    if theta_min <= 0:
        theta_min = 1e-12
    if theta_max <= theta_min:
        theta_max = theta_min * 100.0

    thetas = np.linspace(theta_min, theta_max, steps)
    ds = [violation_bound_delay(th, sigma_bits, rho_bps, C_bps, eps) for th in thetas]
    d = min(ds)
    return max(0.0, d)  # seconds


def e2e_delay_concat(hops, eps_total, theta_grid=None):
    """
    hops: list of dicts with keys {rho_bps, sigma_bits, C_bps}
    把每跳的 delay 上界相加（Boole 分配 ε_i）
    """
    if theta_grid is None:
        theta_min, theta_max, steps = (1e-6, 0.1, 200)
    else:
        # --- 同样强制类型，防 YAML 字符串 ---
        theta_min = float(theta_grid[0])
        theta_max = float(theta_grid[1])
        steps = int(theta_grid[2])

    # 防止 eps=0
    eps_total = float(eps_total)
    if eps_total <= 0:
        eps_total = 1e-12

    eps_i = eps_total / max(1, len(hops))
    total = 0.0
    for h in hops:
        d = single_hop_delay_bound(eps_i, h["rho_bps"], h["sigma_bits"], h["C_bps"],
                                   theta_min=theta_min, theta_max=theta_max, steps=steps)
        total += d
    return total  # seconds

# --------- 简易 Token Bucket 等效参数（从 MMPP/Poisson 近似到 (σ,ρ)） ---------

def approx_sigma_rho_from_mmpp(rates_pps, pkt_bytes, burst_factor=1.0):
    """
    粗略等效：ρ 取平均速率 * L；σ 取 若干个包长度的突发（可按论文场景调参）
    """
    L = pkt_bytes * 8.0
    rho_bps = np.mean(rates_pps) * L
    sigma_bits = burst_factor * L * max(rates_pps) / 10.0
    return sigma_bits, rho_bps

# --------- 百分位（SLO）与 Monte Carlo 包装 ---------

def percentile_delay(delays, p):
    delays = np.sort(np.array(delays))
    k = int(np.ceil(p * len(delays))) - 1
    k = min(max(k,0), len(delays)-1)
    return delays[k]
