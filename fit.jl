"""
    Utility function for fitting a group structure to a data set.
"""
function dg_fit(data, k, param; reg=DG.DEFAULT_REG, dist_pow=2, lr=0.1)
    N, T = size(data)
    
    kw = param == DG.LinearParametrization ? (reg=reg,) : NamedTuple()
    dg = dg_init_random(k, data; param=param, dist_pow=dist_pow, kw...)
    reps = DG.construct_representatives(dg, data)
    
    # Plot representatives and data for comparison.
    plotreps() = begin
        plot(data', legend=false);
        plot!(reps', linewidth=3) |> display
    end

    # Calculate current energy.
    energy(scales=(T/5, T/20, T/250)) =
        [(s, dg_energy(dg, data, s)) for s in scales]

    # Show some statistics.
    printstats(header) = println("""$header
        \tEnergy: $(energy())
    """)

    plotreps()
    printstats("Before:")
    
    # Increase rounds with smaller learning rate.
    rf = -log10(lr) |> round |> Int
    # Smaller tolerances with smaller learning rate.
    atf, rtf = lr*1e-4, lr*1e-2
    vb = true
    res = []
    # These are pretty arbitrary, just chosen to get an okay result
    # on the test data.
    params = [
        (rounds = 30rf, kw = (sigma = T/4)),
        (rounds = 15rf, kw = (sigma = T/10)),
        (rounds = 15rf, kw = (sigma = T/40)),
        (rounds = 30rf, kw = (sigma = T/100, opt = DG.ADAM(lr/2),
                              abstol = atf*1e-2))
    ]
    for p in params
        push!(res, dg_train!(dg, data, p.rounds; reltol=rtf, abstol=atf,
            opt = DG.ADAM(lr), p.kw..., verbose=vb))
    end
    
    reps = DG.construct_representatives(dg, data)

    printstats("After: ")
    plotreps()
    
    (dg=dg, reps=reps)
end