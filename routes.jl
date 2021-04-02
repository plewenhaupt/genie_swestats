using Genie.Router

route("/") do
  serve_static_file("welcome.html")
end

route("/hello") do
  "Welcome to Genie!"
end

using DashboardController
route("/dashboard", DashboardController.dashboard)

using DomforController
route("/domfor", DomforController.domfor)

using FrontpageController
route("/frontpage", FrontpageController.frontpage)

using GenderPopulationController
route("/gender_population", GenderPopulationController.gender_population)

using HousingController
route("/housing", HousingController.housing)

using PoliticiansController
route("/politicians", PoliticiansController.politicians)

using PopulationController
route("/population", PopulationController.population)