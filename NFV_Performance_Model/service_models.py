import numpy as np

class ExponentialService:
    def __init__(self, service_rate):
        self.service_rate = service_rate  # 服务速率

    def service(self, traffic):
        """根据指数服务过程处理流量"""
        service_times = np.random.exponential(1 / self.service_rate, len(traffic))
        return service_times  # 返回服务时间


class OnOffService:
    def __init__(self, rate_on, rate_off, switch_probability):
        self.rate_on = rate_on  # "开"状态服务速率
        self.rate_off = rate_off  # "关"状态服务速率
        self.switch_probability = switch_probability  # 切换概率

    def service(self, traffic):
        """根据开关模型处理流量"""
        states = np.random.choice([1, 0], len(traffic), p=[self.switch_probability, 1 - self.switch_probability])
        service_times = np.where(states == 1, np.random.exponential(1 / self.rate_on, len(traffic)),
                                 np.random.exponential(1 / self.rate_off, len(traffic)))
        return service_times  # 返回服务时间
