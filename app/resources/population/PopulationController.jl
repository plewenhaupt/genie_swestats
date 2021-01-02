module PopulationController
using Genie.Renderer.Html
include("population_data.jl")

function population()
  html(:population, :population,
        pop_df = pop_df,
        popnow_df = popnow_df,
        popgrowth_df = popgrowth_df,
        popgrowthnow_df = popgrowthnow_df,
        layout = :base_site)
end

end
