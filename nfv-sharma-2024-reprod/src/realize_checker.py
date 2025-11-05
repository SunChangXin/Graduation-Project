import time, random

def gen_sfc(vnf_types, length):
    return [random.randint(0, vnf_types-1) for _ in range(length)]

def count_dags(sfc_len, pvr):
    # 每层 pvr 并联，层间串联；可近似计数：pvr^(sfc_len) 条子路径组合
    return pvr ** sfc_len

def realize_time_benchmark(dc_servers, sfc_len, pvr, trials=20, prebuild=False):
    t0 = time.time()
    # 预生成 DAG（仅计数替代，真实实现可枚举并缓存）
    dags = [None]*count_dags(sfc_len, pvr) if prebuild else None
    build_cost = time.time() - t0
    t1 = time.time()
    # 验证（这里用O(1)占位，真实应计算 k(x) 与支配关系）
    checks = min(10**8, count_dags(sfc_len, pvr))  # 控制时间
    s = 0
    for _ in range(min(trials, 50)):
        s += checks
    verify_cost = time.time() - t1
    # print(f"Build time: {build_cost} seconds, Verify time: {verify_cost} seconds")

    return build_cost, verify_cost

