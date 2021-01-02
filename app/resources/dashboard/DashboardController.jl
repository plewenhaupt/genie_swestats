module DashboardController
using Genie.Renderer.Html
include("dashboard_data.jl")

function dashboard()
  html(:dashboard, :dashboard,
        popnow_df = popnow_df,
        agesnow_df = agesnow_df,
        domestic_foreign_bornnow_df = domestic_foreign_bornnow_df,
        edu_level_grouped = edu_level_grouped,
        incomenow_df = incomenow_df,
        housing_grouped = housing_grouped,
        layout = :base_site)
end

end
