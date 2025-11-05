import numpy as np

def parse_fraction(expr, v, r):
    # 将 "1/(v*r)" "1/r" "1" 解析为浮点
    expr = expr.replace("v", str(v)).replace("r", str(r))
    return eval(expr)

def scale_rho_sigma(rho_bps, sigma_bits, X_frac, Y_frac):
    """
    简化缩放：聚合 X（下行合流→上行占比），均分 Y（上行为多上行端口均分）
    对 (σ,ρ) 进行线性缩放（SNC严格推导会对MGF做 log 复合；此处给工程近似）
    """
    rho2 = rho_bps * X_frac * Y_frac
    sigma2 = sigma_bits * X_frac  # 保守：突发随合流比例缩放
    return sigma2, rho2
