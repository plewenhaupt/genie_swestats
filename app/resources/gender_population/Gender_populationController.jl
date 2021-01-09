module GenderPopulationController
using Genie.Renderer.Html
include("gender_population_data.jl")

function gender_population()
  html(:gender_population, :gender_population,
        pop_df = pop_df,
        popnow_df = popnow_df,
        popgrowth_df = popgrowth_df,
        popgrowthnow_df = popgrowthnow_df,
        layout = :base_site)
end

end
