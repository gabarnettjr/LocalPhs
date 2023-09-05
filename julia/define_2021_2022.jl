
include("NbaStat.jl")

a =     [NbaStat("2021_2022", "Atlanta_Hawks",      .524, 113.9, 44.0, 24.6)]
push!(a, NbaStat("2021_2022", "Boston_Celtics",     .622, 111.8, 46.1, 24.8))
push!(a, NbaStat("2021_2022", "Brooklyn_Nets",      .537, 112.9, 44.4, 25.3))
push!(a, NbaStat("2021_2022", "Charlotte_Hornets",  .524, 115.3, 44.6, 28.1))
push!(a, NbaStat("2021_2022", "Chicago_Bulls",      .561, 111.6, 42.3, 23.9))

for stat in a
    if (stat.team == "Brooklyn_Nets")
        println(stat.winPct)
    end
end
