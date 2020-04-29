using DimensionGrouping
using Distributions

function generate_group(T=1000, N=5, seed=1)
    Random.seed!(seed)
    DG.group_walk(
        T, N, start=rand(Uniform(2, 6)), slope=0.0001
    ) |> DG.smooth_walk, T, N
end