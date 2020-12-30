module FrontpageController
  # Build something great

using Genie.Renderer.Html

function frontpage()
  html(:frontpage, :frontpage, layout = :base_site)
end

end
