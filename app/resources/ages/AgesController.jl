module AgesController
using Genie.Renderer.Html
include("ages_data.jl")

function ages()
  html(:ages, :ages,
        mean_median_age_df = mean_median_age_df,
        life_expectancy_df = life_expectancy_df,
        life_expectancynow_df = life_expectancynow_df,
        agesnow_df = agesnow_df,
        layout = :base_site)
end
end
