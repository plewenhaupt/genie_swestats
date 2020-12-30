using DataFrames,
        DataFramesMeta,
        DataFunctions,
        HTTP,
        JSON

# Population_data
pop_df, popnow_df = DataFunctions.population_count()

#Age data
ages_df, agesnow_df = DataFunctions.population_age()

#Domestic or foreign born
domestic_foreign_born_df, domestic_foreign_bornnow_df = DataFunctions.domestic_foreign_born()

#Education level
edu_level_df, edu_levelnow_df = DataFunctions.education_level()

edu_level_grouped = @linq edu_levelnow_df |> groupby([:edu_level, :edu_labels]) |> combine(:count => sum => :count)

#Income
income_df, incomenow_df = DataFunctions.income()
