module HousingController
using Genie.Renderer.Html
include("gender_population_data.jl")

function housing()
  html(:housing, :housing,
        pop_df = pop_df,
        layout = :base_site)
end
end
