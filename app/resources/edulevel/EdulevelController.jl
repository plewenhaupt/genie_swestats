module EdulevelController
using Genie.Renderer.Html
include("edulevels_data.jl")

function edulevels()
  html(:edulevel, :edulevel,
        edu_levels_df = edu_levels_df,
        layout = :base_site)
end

end
