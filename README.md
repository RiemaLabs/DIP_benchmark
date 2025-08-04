# dogecoin_benchmark
## Benchmarking Environment
All benchmarks were conducted on the following hardware and software configuration to ensure reproducibility.

### Server Specifications
- **CPU**: AMD Ryzen 5 5600X 6-Core Processor
  - **Cores**: 6 Cores
  - **Threads**: 12 Threads
  - **Architecture**: x86_64
  - **Base Clock**: 3.70 GHz
- **Memory (RAM)**: 62 GiB
- **Operating System**: Rocky Linux 9.5 (Blue Onyx)
- **Kernel Version**: Linux 5.14.0-503.26.1.el9_5.x86_64

------

### Understanding CPU Usage Metrics
In the benchmark results, the **Avg CPU (%)** column may display values exceeding 100%. This is expected and indicates efficient parallel processing. Here's a brief explanation:

The CPU usage percentage is calculated relative to a single CPU core. Since the benchmark server has **12 threads available**, the theoretical maximum CPU usage is 1200%.

A value such as **`450%`** means that the benchmark process was, on average, fully utilizing the equivalent of **4.5 CPU cores** throughout its execution. This demonstrates that the underlying cryptographic libraries are effectively parallelized to leverage the multi-core architecture of the server, significantly speeding up proof generation.
