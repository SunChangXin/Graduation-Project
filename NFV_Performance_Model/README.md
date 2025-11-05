# NFV_Performance_Model

该项目实现了基于随机网络演算（SNC）的NFV网络性能分析模型，能够预测在不同流量模型和服务模型下的延迟边界。

## 文件结构

- `traffic_models.py`: 定义了泊松过程和马尔科夫调制泊松过程（MMPP）流量模型。
- `service_models.py`: 定义了指数服务过程和开关模型服务过程。
- `stochastic_calculus.py`: 实现了最小加法卷积（Min-Plus Convolution）和延迟边界计算。
- `performance_analysis.py`: 提供了性能分析函数，结合流量和服务模型进行性能评估。
- `main.py`: 主文件，执行流量生成、服务处理和性能分析。


