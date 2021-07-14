using DataFrames,
        DataFunctions,
        DataFramesMeta,
        HTTP,
        JSON

income_df, incomenow_df = DataFunctions.income()

income_df.income_colname = (x -> x == 1 ? "one" :
                              x == 2 ? "two" :
                              x == 3 ? "three" :
                              x == 4 ? "four" :
                              x == 5 ? "five" :
                              x == 6 ? "six" :
                              x == 7 ? "seven" :
                              x == 8 ? "eight" :
                              x == 9 ? "nine" :
                              x == 10 ? "ten" :
                              x == 11 ? "eleven" :
                              x == 12 ? "twelve" :
                              x == 13 ? "thirteen" :
                              x == 14 ? "fourteen" :
                              x == 15 ? "fifteen" :
                              x == 16 ? "sixteen" :
                              x == 17 ? "seventeen" :
                              x == 18 ? "eighteen" :
                              x == 19 ? "nineteen" :
                              x == 20 ? "twenty" :
                              x == 21 ? "twentyone" :
                              x == 22 ? "twentytwo" :
                              x == 23 ? "twentythree" :
                              x == 24 ? "twentyfour" :
                              x == 25 ? "twentyfive" :
                              x == 26 ? "twentysix" :
                              x).(income_df.level)

income_levels_df = @chain income_df begin
                     @select(:income_colname, :year, :total_income)
                     unstack(:income_colname, :total_income)
             end

conversion_cols = [Symbol(col) for col in names(income_levels_df)[2:length(names(income_levels_df))]]
for col in conversion_cols
income_levels_df[!, col] = map(x->convert(Int64, x), income_levels_df[!, col])
end

income_levels_df[!, :year] = map(x->convert(String, x), income_levels_df[!, :year])
