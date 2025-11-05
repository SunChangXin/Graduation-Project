import numpy as np
from stochastic_calculus import StochasticNetworkCalculus


def analyze_performance(traffic_model, service_model, violation_probability=1e-6):
    # 生成流量数据，不需要传递 time_period
    arrival_traffic = traffic_model.generate_traffic()  # 使用初始化时的 time_period
    service_process = service_model.service(arrival_traffic)

    snc = StochasticNetworkCalculus(service_process, arrival_traffic)
    delay_bound = snc.calculate_delay_bound(arrival_traffic, service_process, violation_probability)

    return delay_bound

