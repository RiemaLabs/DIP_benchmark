#!/bin/bash

# ==============================================================================
#  Automatic Circom Benchmark Runner
#
#  This script automatically finds all .r1cs files in the circuits directory,
#  checks if their corresponding _input.json file is valid (does not contain "TODO"),
#  and runs the benchmark for each valid circuit.
# ==============================================================================

BENCH_RUNNER="./target/release/dogecoin_zkp_generator_qa1"
CIRCUITS_DIR="./circuits"
RESULTS_FILE="benchmark_results.log"

echo "--- Checking and compiling benchmark runner ---"
if [ ! -f "$BENCH_RUNNER" ]; then
    echo "Benchmark runner not found. Building project in release mode..."
    cargo build --release
else
    echo "Benchmark runner found. Skipping build."
fi

echo "Starting benchmarks... Results will be saved to ${RESULTS_FILE}"
> "$RESULTS_FILE"

for r1cs_file in "$CIRCUITS_DIR"/*.r1cs; do
    
    base_name=$(basename "$r1cs_file" .r1cs)
    
    display_name="${base_name}.circom"
    wasm_file="${CIRCUITS_DIR}/${base_name}_js/${base_name}.wasm"
    input_json="${CIRCUITS_DIR}/${base_name}_input.json"

    echo "============================================================" | tee -a "$RESULTS_FILE"
    echo "Processing Circuit: $display_name" | tee -a "$RESULTS_FILE"

    if [ -f "$input_json" ] && ! grep -q "TODO" "$input_json"; then
        echo "✅ Valid input found. Running benchmark..." | tee -a "$RESULTS_FILE"

        if [ ! -f "$wasm_file" ]; then
            echo "❌ Error: WASM file not found at ${wasm_file}. Skipping." | tee -a "$RESULTS_FILE"
            echo "" | tee -a "$RESULTS_FILE"
            continue
        fi
        { /usr/bin/time -v "$BENCH_RUNNER" "$r1cs_file" "$wasm_file" "$input_json"; } 2>> "$RESULTS_FILE"

    else
        echo "⏭️  Skipping: Input file '${input_json}' contains 'TODO' or is missing." | tee -a "$RESULTS_FILE"
    fi
    
    echo "" | tee -a "$RESULTS_FILE"
done

echo "🎉 All benchmarks processed!"
echo "Please check the ${RESULTS_FILE} file for detailed performance metrics."
