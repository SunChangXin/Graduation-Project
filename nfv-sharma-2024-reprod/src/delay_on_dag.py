from .snc_math import e2e_delay_concat, approx_sigma_rho_from_mmpp

def dag_path_delay_mmpp(path_servers, rates_pps, pkt_bytes, C_bps, eps, theta_grid):
    sigma, rho = approx_sigma_rho_from_mmpp(rates_pps, pkt_bytes)
    hops = []
    for _ in path_servers:
        hops.append({"rho_bps": rho, "sigma_bits": sigma, "C_bps": C_bps})
    d = e2e_delay_concat(hops, eps_total=eps, theta_grid=theta_grid)
    return d  # seconds
