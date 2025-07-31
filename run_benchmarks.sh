#!/bin/bash

# ==============================================================================
#  Automatic Circom Benchmark Runner
#
#  This script automatically finds all .r1cs files in the circuits directory,
#  checks if their corresponding _input.json file is valid (does not contain "TODO"),
#  and runs the benchmark for each valid circuit.
# ==============================================================================

# 设置脚本在遇到错误时立即退出
#set -e

# --- 1. 定义路径和变量 ---
BENCH_RUNNER="./target/release/dogecoin_zkp_generator_qa1"
CIRCUITS_DIR="./circuits"
RESULTS_FILE="benchmark_results.log"

# --- 2. 编译 Rust 程序 (如果需要) ---
echo "--- Checking and compiling benchmark runner ---"
if [ ! -f "$BENCH_RUNNER" ]; then
    echo "Benchmark runner not found. Building project in release mode..."
    cargo build --release
else
    echo "Benchmark runner found. Skipping build."
fi

# --- 3. 循环执行并记录结果 ---
echo "Starting benchmarks... Results will be saved to ${RESULTS_FILE}"
> "$RESULTS_FILE" # 清空旧的日志文件

# 遍历 circuits 目录下的所有 .r1cs 文件来自动发现电路
for r1cs_file in "$CIRCUITS_DIR"/*.r1cs; do
    
    # 从 R1CS 文件路径中提取基本名称, 例如从 "./circuits/AND@gates.r1cs" 提取 "AND@gates"
    base_name=$(basename "$r1cs_file" .r1cs)
    
    # 根据基本名称构建其他文件的路径
    display_name="${base_name}.circom"
    wasm_file="${CIRCUITS_DIR}/${base_name}_js/${base_name}.wasm"
    input_json="${CIRCUITS_DIR}/${base_name}_input.json"

    echo "============================================================" | tee -a "$RESULTS_FILE"
    echo "Processing Circuit: $display_name" | tee -a "$RESULTS_FILE"

    # 检查 input.json 文件是否存在并且不包含 "TODO"
    if [ -f "$input_json" ] && ! grep -q "TODO" "$input_json"; then
        # 如果输入文件有效，则运行 benchmark
        echo "✅ Valid input found. Running benchmark..." | tee -a "$RESULTS_FILE"

        # 检查 WASM 文件是否存在
        if [ ! -f "$wasm_file" ]; then
            echo "❌ Error: WASM file not found at ${wasm_file}. Skipping." | tee -a "$RESULTS_FILE"
            echo "" | tee -a "$RESULTS_FILE"
            continue
        fi
        
        # 使用 /usr/bin/time -v 详细测量性能, 并将结果追加到日志文件
        # 注意: { ...; } 2>> ... 这种语法确保 time 命令的输出 (stderr) 被重定向
        { /usr/bin/time -v "$BENCH_RUNNER" "$r1cs_file" "$wasm_file" "$input_json"; } 2>> "$RESULTS_FILE"

    else
        # 如果输入文件包含 "TODO" 或不存在，则跳过
        echo "⏭️  Skipping: Input file '${input_json}' contains 'TODO' or is missing." | tee -a "$RESULTS_FILE"
    fi
    
    echo "" | tee -a "$RESULTS_FILE"
done

echo "🎉 All benchmarks processed!"
echo "Please check the ${RESULTS_FILE} file for detailed performance metrics."
