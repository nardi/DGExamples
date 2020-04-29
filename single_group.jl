import Pkg
Pkg.activate(@__DIR__)

include.(["generate_data.jl", "fit.jl"])

begin # Imports.
    using Revise

    using Distributions, LinearAlgebra
    import Random, GR
    using StatsPlots;
    gr(); plot() # Immediately called so initialization happens.
    newplotwindow() = begin GR.emergencyclosegks(); plot() end

    using DimensionGrouping
end

# Wait for user input.
pause() = begin println("Press enter to continue."); readline() end

# Keep track of results.
res = []
store(x) = push!(res, x)
last(p) = res[end][:p]

data_1g, = generate_group()

# Regular k-means.
dg_fit(data_1g, 1, DG.Nonparametric, dist_pow=2) |> store; pause()
# Compare to mean.
plot(last(:reps)', legend=false); plot!(mean(data_1g, dims=1)', linestyle=:dash); pause()

# k-'medians'.
dg_fit(data_1g, 1, DG.Nonparametric, dist_pow=1) |> store; pause()
# Compare to median.
plot(last(:reps)', legend=false); plot!(median(data_1g, dims=1)', linestyle=:dash); pause()
