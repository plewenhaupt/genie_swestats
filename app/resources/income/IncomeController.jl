module IncomeController
using Genie.Renderer.Html
include("income_data.jl")

function income()
  html(:income, :income,
      income_levels_df = income_levels_df,
        layout = :base_site)
end

end
