using DataFrames,
        DataFunctions,
        DataFramesMeta,
        HTTP,
        JSON

edu_level_df, edu_levelnow_df = DataFunctions.education_level()

edu_levels_df = @chain edu_level_df begin
                     groupby([:edu_colname, :year])
                     @combine(:count = sum(:count))
                     unstack(:edu_colname, :count)
             end

conversion_cols = [Symbol(col) for col in names(edu_levels_df)[2:length(names(edu_levels_df))]]
for col in conversion_cols
edu_levels_df[!, col] = map(x->convert(Int64, x), edu_levels_df[!, col])
end
