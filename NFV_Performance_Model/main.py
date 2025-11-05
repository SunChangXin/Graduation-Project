import numpy as np
from traffic_models import PoissonProcess, MMPP
from service_models import ExponentialService, OnOffService
from performance_analysis import analyze_performance

def main():
    # 定义流量模型，指定时间周期
    poisson = PoissonProcess(arrival_rate=0.1, time_period=1000)  # 示例：泊松流量
    mmpp = MMPP(rate_state_1=0.1, rate_state_2=0.2, transition_rate_1=0.5, transition_rate_2=0.3, time_period=1000)

    # 定义服务模型
    exponential_service = ExponentialService(service_rate=0.1)  # 示例：指数服务
    on_off_service = OnOffService(rate_on=0.15, rate_off=0.05, switch_probability=0.8)

    # 性能分析
    delay_bound_poisson = analyze_performance(poisson, exponential_service)
    delay_bound_mmpp = analyze_performance(mmpp, on_off_service)

    print(f"Poisson Process Delay Bound: {delay_bound_poisson}")
    print(f"MMPP Process Delay Bound: {delay_bound_mmpp}")

if __name__ == "__main__":
    main()


