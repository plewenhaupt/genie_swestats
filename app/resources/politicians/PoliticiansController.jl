module PoliticiansController
using Genie.Renderer.Html
include("politicians_data.jl")

function politicians()
  html(:politicians, :politicians, df_age = df_age, layout = :base_site)
end

end
