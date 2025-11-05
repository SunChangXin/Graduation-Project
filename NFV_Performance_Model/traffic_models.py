import numpy as np

class PoissonProcess:
    def __init__(self, arrival_rate, time_period):
        self.arrival_rate = arrival_rate  # 到达率
        self.time_period = time_period  # 时间周期

    def generate_traffic(self):
        """生成基于Poisson过程的流量数据"""
        arrival_times = np.random.exponential(1 / self.arrival_rate, self.time_period)
        return np.cumsum(arrival_times)  # 返回累计到达时间


class MMPP:
    def __init__(self, rate_state_1, rate_state_2, transition_rate_1, transition_rate_2, time_period):
        self.rate_state_1 = rate_state_1  # 状态1的到达率
        self.rate_state_2 = rate_state_2  # 状态2的到达率
        self.transition_rate_1 = transition_rate_1  # 从状态1到状态2的转移率
        self.transition_rate_2 = transition_rate_2  # 从状态2到状态1的转移率
        self.time_period = time_period  # 模拟时长

    def generate_traffic(self):
        """生成基于MMPP过程的流量数据"""
        state = 1  # 初始状态设为1
        traffic = []
        time = 0
        while time < self.time_period:
            if state == 1:
                inter_arrival_time = np.random.exponential(1 / self.rate_state_1)
                time += inter_arrival_time
                traffic.append(time)
                if np.random.rand() < self.transition_rate_1 / (self.transition_rate_1 + self.transition_rate_2):
                    state = 2  # 转移到状态2
            else:
                inter_arrival_time = np.random.exponential(1 / self.rate_state_2)
                time += inter_arrival_time
                traffic.append(time)
                if np.random.rand() < self.transition_rate_2 / (self.transition_rate_1 + self.transition_rate_2):
                    state = 1  # 转移到状态1
        return np.array(traffic)
