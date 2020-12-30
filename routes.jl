using Genie.Router

route("/") do
  serve_static_file("welcome.html")
end

route("/hello") do
  "Welcome to Genie!"
end

using FrontpageController
route("/frontpage", FrontpageController.frontpage)

using DashboardController
route("/dashboard", DashboardController.dashboard)

using PoliticiansController
route("/politicians", PoliticiansController.politicians)

using PopulationController
route("/population", PopulationController.population)
