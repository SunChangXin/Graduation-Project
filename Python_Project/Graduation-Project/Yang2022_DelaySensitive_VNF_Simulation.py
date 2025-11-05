import numpy as np

# 网络参数
num_nodes = 10
num_links = 20
link_bandwidth = np.random.uniform(30, 50, num_links)  # 链接带宽（30-50 Mbps）
node_capacity = np.random.uniform(100, 150, num_nodes)  # 节点处理能力（100-150 单位）

# 流量请求参数
num_requests = 100  # 流量请求数
traffic_volume = np.random.randint(50, 101, num_requests)  # 流量体积（50-100 Mbps）
packet_size = np.random.randint(5, 11, num_requests)  # 数据包大小（5-10 MB）
sfc_length = np.random.randint(5, 11, num_requests)  # SFC中的VNF数量（5-10）
vnf_delay = np.random.uniform(10, 25, num_requests)  # VNF处理延迟（10-25 ms）
link_avail = np.random.choice([0.99, 0.999, 0.9999], num_links)  # 链接可用性
node_avail = np.random.choice([0.99, 0.999, 0.9999], num_nodes)  # 节点可用性

# 模拟延迟敏感和可用性感知的调度
def simulate_vnf_scheduling():
    accepted_requests = 0
    total_used_nodes = 0
    total_delay = 0
    for request in range(num_requests):
        # 随机VNF放置和路由仿真
        sfc_delay = np.sum(np.random.uniform(1, 5, sfc_length[request]))  # 累加VNF处理延迟
        total_delay += sfc_delay
        if sfc_delay <= 50:  # 延迟约束检查（50 ms）
            accepted_requests += 1
            total_used_nodes += np.random.randint(1, 4)  # 每个请求使用的随机节点数

    # 计算接收率、平均使用节点数和延迟
    acceptance_ratio = accepted_requests / num_requests
    avg_nodes_used = total_used_nodes / accepted_requests if accepted_requests > 0 else 0
    avg_delay = total_delay / accepted_requests if accepted_requests > 0 else 0
    return acceptance_ratio, avg_nodes_used, avg_delay

# 运行仿真
acceptance_ratio, avg_nodes_used, avg_delay = simulate_vnf_scheduling()

print(f"接收率: {acceptance_ratio:.2f}")
print(f"平均使用节点数: {avg_nodes_used:.2f}")
print(f"平均延迟: {avg_delay:.2f} ms")
