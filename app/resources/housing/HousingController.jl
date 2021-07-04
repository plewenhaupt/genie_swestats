module HousingController
using Genie.Renderer.Html
include("gender_population_data.jl")

function housing()
  html(:housing, :housing,
        totalhousing_df = totalhousing_df,
        layout = :base_site)
end
end
