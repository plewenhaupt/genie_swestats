using DataFrames,
        DataFunctions,
        DataFramesMeta,
        HTTP,
        JSON

housing_df, housingnow_df = DataFunctions.housing()

totalhousing_df = @linq housing_df |> where(:age .== "total")
