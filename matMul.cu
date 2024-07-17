#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "jh_timer.h"

#define BLOCK_SIZE 16

#define SIZE_M 1024
#define SIZE_N 2048
#define SIZE_K 1024

__global__ void matMul(int* matA, int* matB, int* matC, int m, int n, int k);

int main(void)
{
    // set matrix size
    int m = SIZE_M;
    int n = SIZE_N;
    int k = SIZE_K;
    printf("Matrix size: A(%d, %d), B(%d, %d), C(%d, %d)\n", m, k, k, n, m, n);

    int sizeA = m * k;
    int sizeB = k * n;
    int sizeC = m * n;

    // initialize timer
    JH_timer timer = timer_init(4);

    // host memory allocation
    int* A = NULL;
    int* B = NULL;
    int* C = NULL;
    
    A = (int*)malloc(sizeof(int) * sizeA);
    B = (int*)malloc(sizeof(int) * sizeB);
    C = (int*)malloc(sizeof(int) * sizeC);

    // generate input matrices
	for (int i = 0; i < sizeA; i++) A[i] = ((rand() % 10) + ((rand() % 100) / 100.0));
	for (int i = 0; i < sizeB; i++) B[i] = ((rand() % 10) + ((rand() % 100) / 100.0));

    // device memory allocation
    int *dA, *dB, *dC;
    cudaMalloc(&dA, sizeof(int) * sizeA);
    cudaMalloc(&dB, sizeof(int) * sizeB);
    cudaMalloc(&dC, sizeof(int) * sizeC);

    setTimerName(&timer, 0, "matMul (GPU) total");
    onTimer(&timer, 0);

    // host -> device memory transfer
    setTimerName(&timer, 1, "Host -> Device memory transfer");
    onTimer(&timer, 1);
    cudaMemcpy(dA, A, sizeof(int) * sizeA, cudaMemcpyHostToDevice);
    cudaMemcpy(dB, B, sizeof(int) * sizeB, cudaMemcpyHostToDevice);
    offTimer(&timer, 1);

    // matrix multiplication on device (GPU)
    dim3 gridDim(ceil((float)n / BLOCK_SIZE), ceil((float)m / BLOCK_SIZE));
    dim3 blockDim(BLOCK_SIZE, BLOCK_SIZE);
    printf("Grid shape: (%d, %d, %d)\n", gridDim.x, gridDim.y, gridDim.z);
    printf("Block shape: (%d, %d, %d)\n", blockDim.x, blockDim.y, blockDim.z);

    setTimerName(&timer, 2, "matMul (GPU)");
    onTimer(&timer, 2);
    matMul<<<gridDim, blockDim>>>(dA, dB, dC, m, n, k);
    cudaDeviceSynchronize();
    printf("matMul (GPU) ended.\n");
    offTimer(&timer, 2);

    // device -> host memory transfer
    setTimerName(&timer, 3, "Device -> Host memory transfer");
    onTimer(&timer, 3);
    cudaMemcpy(C, dC, sizeof(int) * sizeC, cudaMemcpyDeviceToHost);
    offTimer(&timer, 3);

    offTimer(&timer, 0);

    cudaFree(dA);
    cudaFree(dB);
    cudaFree(dC);

    // print log to stdout
    printLog(&timer, NULL);

    free(A);
    free(B);
    free(C);

    return 0;
}

__global__ void matMul(int* matA, int* matB, int* matC, int m, int n, int k)
{
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    int col = blockDim.x * blockIdx.x + threadIdx.x;

    // If the index is out of range, do nothing
    if (row >= m || col >= n) return;

    int index = row * n + col;
    matC[index] = 0;

    for (int p = 0; p < k; p++)
        matC[index] += matA[row * k + p] * matB[p * n + col];
}
