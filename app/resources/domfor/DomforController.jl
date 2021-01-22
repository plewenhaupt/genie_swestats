module DomforController
using Genie.Renderer.Html
include("domfor_data.jl")

function domfor()
  html(:domfor, :domfor,
        domestic_foreign_born_df = domestic_foreign_born_df,
        domestic_foreign_bornnow_df = domestic_foreign_bornnow_df,
        layout = :base_site)
end
end
