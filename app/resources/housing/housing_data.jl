using DataFrames,
        DataFunctions,
        DataFramesMeta,
        HTTP,
        JSON

housing_df, housingnow_df = DataFunctions.housing_form()

totalhousing_df = @chain housing_df begin
                        @subset(:age .== "total")
                        @select(:year, :housing_form, :total_housing)
                        unstack(:housing_form, :total_housing)
                end

conversion_cols = [Symbol(col) for col in names(totalhousing_df)[2:length(names(totalhousing_df))]]
for col in conversion_cols
totalhousing_df[!, col] = map(x->convert(Int64, x), totalhousing_df[!, col])
end
