using DataFrames,
        DataFramesMeta,
        HTTP,
        JSON

using DataFunctions

pop_df, popnow_df = DataFunctions.population_count()

popgrowth_df, popgrowthnow_df = DataFunctions.population_growth()
