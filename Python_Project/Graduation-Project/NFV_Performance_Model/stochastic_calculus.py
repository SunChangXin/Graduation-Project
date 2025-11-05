import numpy as np

class StochasticNetworkCalculus:
    def __init__(self, service_process, arrival_process):
        self.service_process = service_process
        self.arrival_process = arrival_process

    def min_plus_convolution(self, arrival, service):
        """实现最小加法卷积"""
        return np.minimum(arrival, service)  # 使用最小值函数比较两个数组

    def calculate_delay_bound(self, arrival, service, violation_probability):
        """计算延迟边界"""
        convolution_result = self.min_plus_convolution(arrival, service)
        latency_bound = np.max(convolution_result)  # 计算延迟上限
        return latency_bound
