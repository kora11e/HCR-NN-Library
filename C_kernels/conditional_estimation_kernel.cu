#include <torch/extension.h>
#include <cuda.h>
#include <cuda_runtime.h>

// Kernel to compute denominator (i=0 slice)
__global__ void denominator_kernel(
    const float* __restrict__ a,
    const float* __restrict__ fy,
    const float* __restrict__ fz,
    float* denom,
    int D
) {
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    int k = blockIdx.y * blockDim.y + threadIdx.y;

    if (j < D && k < D) {
        atomicAdd(denom, a[0 * D * D + j * D + k] * fy[j] * fz[k]);
    }
}

// Kernel to compute context[i] for all i
__global__ void context_kernel(
    const float* __restrict__ a,
    const float* __restrict__ fy,
    const float* __restrict__ fz,
    float* context,
    int D
) {
    int i = blockIdx.x;
    int j = threadIdx.y;
    int k = threadIdx.x;

    __shared__ float partial[32][32]; // assuming D <= 32 (can generalize)

    float val = 0.0f;
    if (j < D && k < D) {
        val = a[i * D * D + j * D + k] * fy[j] * fz[k];
    }
    partial[j][k] = val;

    __syncthreads();

    // Reduction along j,k
    if (j == 0 && k == 0) {
        float sum = 0.0f;
        for (int jj = 0; jj < D; jj++) {
            for (int kk = 0; kk < D; kk++) {
                sum += partial[jj][kk];
            }
        }
        context[i] = sum;
    }
}

void denominator_cuda() {

}

void context_cuda() {

}