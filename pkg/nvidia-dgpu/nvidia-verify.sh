#\!/bin/sh
echo "=== NVIDIA dGPU Verification ==="
echo ""
echo "--- nvidia-smi ---"
nvidia-smi 2>&1 || echo "nvidia-smi failed (expected without GPU hardware)"
echo ""
echo "--- CUDA Runtime ---"
ls -la /usr/lib/x86_64-linux-gnu/libcuda.so* 2>/dev/null
ls -la /usr/lib/x86_64-linux-gnu/libcudart.so* 2>/dev/null
echo ""
echo "--- nvcc version ---"
nvcc --version 2>&1 || echo "nvcc not found"
echo ""
echo "--- vectorAdd ---"
if [ -f /usr/local/bin/vectorAdd ]; then
    echo "vectorAdd binary: present"
    /usr/local/bin/vectorAdd 2>&1 || echo "vectorAdd failed (expected without GPU hardware)"
else
    echo "vectorAdd binary: not compiled (source available in cuda samples)"
fi
echo ""
echo "--- NVIDIA kernel modules (from host) ---"
ls /lib/modules/*/kernel/nvidia-595-open/*.ko 2>/dev/null || echo "kernel modules not visible (check binds)"
echo ""
echo "=== Verification complete ==="
