using DataFrames,
        DataFramesMeta,
        HTTP,
        JSON

using DataFunctions

# Get the original population age data
ages_df, agesnow_df = DataFunctions.population_age()

# Calculate the mean age for the population for each year
mean_age_sym_cols = [:year, :mean_age_men, :mean_age_total, :mean_age_women]
#Create arrays bound to column name symbols
mean_age_cols = [col => [] for col in mean_age_sym_cols]

#Create empty dataframe to capture data
mean_age_df = DataFrame(mean_age_cols...)

# Get the minimum and maximum years for the loop
mean_age_year_min = minimum(ages_df.year)
mean_age_year_max = maximum(ages_df.year)

# Populate the mean age dataframe
for i in mean_age_year_min:mean_age_year_max
        mean_ages = @linq ages_df |> where(:year .== i) |>
                                    # Create the sums of the ages (dividend)
                                    transform(total_age_sum = :age .* :total_ages,
                                              men_age_sum = :age .* :male_ages,
                                              women_age_sum = :age .* :female_ages)

        # Calculate the mean for sexes and total
        mean_age_men = sum(mean_ages.men_age_sum)/sum(mean_ages.male_ages)
        mean_age_total = sum(mean_ages.total_age_sum)/sum(mean_ages.total_ages)
        mean_age_women = sum(mean_ages.women_age_sum)/sum(mean_ages.female_ages)
        row = vcat(i, mean_age_men, mean_age_total, mean_age_women)
        push!(mean_age_df,row)
end

# Get the median age for each year
# Calculate the mean age for the population for each year
median_age_sym_cols = [:year, :median_age_men, :median_age_total, :median_age_women]
#Create arrays bound to column name symbols
median_age_cols = [col => [] for col in median_age_sym_cols]

#Create empty dataframe to capture data
median_age_df = DataFrame(median_age_cols...)

# Get the minimum and maximum years for the loop
median_age_year_min = minimum(ages_df.year)
median_age_year_max = maximum(ages_df.year)

# Populate the median age dataframe
for i in median_age_year_min:median_age_year_max
        median_ages = @linq ages_df |> where(:year .== i)

        # Get median for each gender category for the year
        median_arr = []
        gender_cols = [:male_ages, :total_ages, :female_ages]

        for x in gender_cols
                positions = sum(median_ages[!, x])
                median_position = (positions + 1)/2
                median_ages.cumsum = cumsum(median_ages[!, x])
                median_slice = @linq median_ages |> where(:cumsum .< median_position)
                median = median_slice[nrow(median_slice), :age]

                push!(median_arr, median)
        end

        row = vcat(i, median_arr)
        push!(median_age_df, row)
end

# Join mean and median age dfs
mean_median_age_df = leftjoin(mean_age_df, median_age_df, on = :year)

# Type conversion
mean_median_age_df[!, :year] = map(x->convert(Int64, x), mean_median_age_df[!, :year])
conversion_cols = [Symbol(col) for col in names(mean_median_age_df)[2:length(names(mean_median_age_df))]]
for col in conversion_cols
mean_median_age_df[!, col] = map(x->round(convert(Float64, x),digits = 2), mean_median_age_df[!, col])
end

life_expectancy_df, life_expectancynow_df = DataFunctions.life_expectancy()
