module DataFunctions
using CategoricalArrays,
        DataFrames,
        DataFramesMeta,
        HTTP,
        JSON

function SCB_API_pull(url, json)
        # send the request
        r = HTTP.request("POST", url,
                         ["Content-Type" => "application/json"],
                         JSON.json(json))

        # retrieve the response body as a string
        body = @linq r.body |> String() |> JSON.parse()

        # Get data
        data = body["data"]

        #Get column data
        columns = body["columns"]

        #Create empty array to capture column names
        colnames = []

        #Loop through dictionary to get column names and push to array
        for x in (1:length(columns))
                name = columns[x]["text"]
                push!(colnames, name)
        end

        sym_cols = [Symbol(col) for col in colnames]
        #Create arrays bound to column name symbols
        cols = [col => [] for col in sym_cols]

        #Create empty dataframe to capture data
        df = DataFrame(cols...)

        #Loop through data and push to dataframe
        for x in (1:length(data))
                key = data[x]["key"]
                values = data[x]["values"]

                # Handle deviant data
                if values == [".."]
                    values = "0"
                end

                row = vcat(key, values)
                push!(df, row)
        end

        return df
end

function population_count()
    url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefUtvKon1749"

    pop_json = JSON.parse("""{
    "query": [
    {
      "code": "Kon",
      "selection": {
        "filter": "item",
        "values": [
          "1",
          "2",
          "1+2"
        ]
      }
    },
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": [
          "000000LV"
        ]
      }
    }
    ],
    "response": {
    "format": "json"
    }
    }""")

    raw_df = @linq SCB_API_pull(url, pop_json)

    new_colnames = [:year, :male_pop, :female_pop, :total_pop]

    df_pre = @linq raw_df |> unstack(:kön, :Folkmängd) |>
                                rename!(new_colnames)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    # Add year on year diff
    diff_colnames = [:total_diff, :male_diff, :female_diff]

    for i in range(1, length = length(diff_colnames))
        df_pre[!, diff_colnames[i]] = @linq diff(df_pre[!, new_colnames[i+1]]) |> pushfirst!(0)
    end

    pop_df = df_pre

    lastpop = pop_df[nrow(pop_df), :]

    return pop_df, lastpop
end

function births()
    url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefUtvKon1749"

    births_json = JSON.parse("""{
      "query": [
        {
          "code": "Kon",
          "selection": {
            "filter": "item",
            "values": [
              "1",
              "2",
              "1+2"
            ]
          }
        },
        {
          "code": "ContentsCode",
          "selection": {
            "filter": "item",
            "values": [
              "0000001H"
            ]
          }
        }
      ],
      "response": {
        "format": "json"
      }
    }""")

    raw_df = SCB_API_pull(url, births_json)

    new_colnames = [:year, :male_births, :female_births, :total_births]

    df_pre = @linq raw_df |> unstack(:kön, :Födda) |>
                                    rename!(new_colnames)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    # Add year on year diff
    diff_colnames = [:male_diff, :female_diff, :total_diff]

    for i in range(1, length = length(diff_colnames))
        df_pre[!, diff_colnames[i]] = @linq diff(df_pre[!, new_colnames[i+1]]) |> pushfirst!(0)
    end

    births_df = df_pre

    birthsnow_df = births_df[nrow(births_df), :]

    return births_df, birthsnow_df
end

function deaths()
    url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefUtvKon1749"

    deaths_json = JSON.parse("""{
      "query": [
        {
          "code": "Kon",
          "selection": {
            "filter": "item",
            "values": [
              "1",
              "2",
              "1+2"
            ]
          }
        },
        {
          "code": "ContentsCode",
          "selection": {
            "filter": "item",
            "values": [
              "0000001F"
            ]
          }
        }
      ],
      "response": {
        "format": "json"
      }
    }""")

    raw_df = SCB_API_pull(url, deaths_json)

    new_colnames = [:year, :male_deaths, :female_deaths, :total_deaths]

    df_pre = @linq raw_df |> unstack(:kön, :Döda) |>
                                    rename!(new_colnames)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    # Add year on year diff
    diff_colnames = [:male_diff, :female_diff, :total_diff]

    for i in range(1, length = length(diff_colnames))
        df_pre[!, diff_colnames[i]] = @linq diff(df_pre[!, new_colnames[i+1]]) |> pushfirst!(0)
    end

    deaths_df = df_pre

    deathsnow_df = deaths_df[nrow(deaths_df), :]

    return deaths_df, deathsnow_df
end

function immigration()
    url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefUtvKon1749"

    immigration_json = JSON.parse("""{
      "query": [
        {
          "code": "Kon",
          "selection": {
            "filter": "item",
            "values": [
              "1",
              "2",
              "1+2"
            ]
          }
        },
        {
          "code": "ContentsCode",
          "selection": {
            "filter": "item",
            "values": [
              "000000LX"
            ]
          }
        }
      ],
      "response": {
        "format": "json"
      }
    }""")

    raw_df = SCB_API_pull(url, immigration_json)

    new_colnames = [:year, :male_immigration, :female_immigration, :total_immigration]

    df_pre = @linq raw_df |> unstack(:kön, :Invandringar) |>
                                        rename!(new_colnames)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    # Add year on year diff
    diff_colnames = [:male_diff, :female_diff, :total_diff]

    for i in range(1, length = length(diff_colnames))
        df_pre[!, diff_colnames[i]] = @linq diff(df_pre[!, new_colnames[i+1]]) |> pushfirst!(0)
    end

    immigration_df = df_pre

    immigrationnow_df = immigration_df[nrow(immigration_df), :]

    return immigration_df, immigrationnow_df
end

function emigration()
    url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101G/BefUtvKon1749"

    emigration_json = JSON.parse("""{
      "query": [
        {
          "code": "Kon",
          "selection": {
            "filter": "item",
            "values": [
              "1",
              "2",
              "1+2"
            ]
          }
        },
        {
          "code": "ContentsCode",
          "selection": {
            "filter": "item",
            "values": [
              "0000001G"
            ]
          }
        }
      ],
      "response": {
        "format": "json"
      }
    }""")

    raw_df = SCB_API_pull(url, emigration_json)

    new_colnames = [:year, :male_emigration, :female_emigration, :total_emigration]

    df_pre = @linq raw_df |> unstack(:kön, :Utvandringar) |>
                                        rename!(new_colnames)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    # Add year on year diff
    diff_colnames = [:male_diff, :female_diff, :total_diff]

    for i in range(1, length = length(diff_colnames))
        df_pre[!, diff_colnames[i]] = @linq diff(df_pre[!, new_colnames[i+1]]) |> pushfirst!(0)
    end

    emigration_df = df_pre

    emigrationnow_df = emigration_df[nrow(emigration_df), :]

    return emigration_df, emigrationnow_df
end

function population_growth()
    births_df, birthsnow_df = births()
    deaths_df, deathsnow_df = deaths()
    immigration_df, immigrationnow_df = immigration()
    emigration_df, emigrationnow_df = emigration()

    births_deaths_df = @linq leftjoin(births_df, deaths_df, on=:year, makeunique = true) |>
                        rename!(Dict(:total_diff => "total_diff_births",
                                        :male_diff => "male_diff_births",
                                        :female_diff => "female_diff_births",
                                        :total_diff_1 => "total_diff_deaths",
                                        :male_diff_1 => "male_diff_deaths",
                                        :female_diff_1 => "female_diff_deaths"))

    immigration_emigration_df = @linq leftjoin(immigration_df, emigration_df, on=:year, makeunique = true) |>
                        rename!(Dict(:total_diff => "total_diff_immigration",
                                        :male_diff => "male_diff_immigration",
                                        :female_diff => "female_diff_immigration",
                                        :total_diff_1 => "total_diff_emigration",
                                        :male_diff_1 => "male_diff_emigration",
                                        :female_diff_1 => "female_diff_emigration"))

    population_growth_df = @linq leftjoin(births_deaths_df, immigration_emigration_df, on=:year) |>
                                    transform(net_births = :total_births - :total_deaths,
                                              net_migration = :total_immigration - :total_emigration) |>
                                    transform(net_population_growth = :net_births + :net_migration) |>
                                    transform(net_male_births = :male_births - :male_deaths,
                                              net_female_births = :female_births - :female_deaths,
                                              net_male_migration = :male_immigration - :male_emigration,
                                              net_female_migration = :female_immigration - :female_emigration) |>
                                    transform(net_male_growth = :net_male_births + :net_male_migration,
                                              net_female_growth = :net_female_births + :net_female_migration)

    popgrowthnow_df = population_growth_df[nrow(population_growth_df), :]

    return population_growth_df, popgrowthnow_df
end

function domestic_foreign_born()
    url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101Q/UtlSvBakgFin"

    dom_for_json = JSON.parse("""{
      "query": [
        {
          "code": "UtlBakgrund",
          "selection": {
            "filter": "item",
            "values": [
              "08",
              "4",
              "5",
              "6"
            ]
          }
        }
      ],
      "response": {
        "format": "json"
      }
    }""")

    raw_df = SCB_API_pull(url, dom_for_json)

    new_colnames = [:year, :foreign_born, :dom_born_two_foreign_parents, :dom_born_one_foreign_parent, :dom_born]

    df_pre = @linq raw_df |> unstack(Symbol(names(raw_df)[1]), Symbol(names(raw_df)[3])) |>
                                                    rename!(new_colnames)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    # Add year on year diff
    diff_colnames = [:foreign_born_diff, :dom_born_two_foreign_parents_diff, :dom_born_one_foreign_parent_diff, :dom_born_diff]

    for i in range(1, length = length(diff_colnames))
        df_pre[!, diff_colnames[i]] = @linq diff(df_pre[!, new_colnames[i+1]]) |> pushfirst!(0)
    end

    df_pre = @linq df_pre |> transform(totalborn = :foreign_born + :dom_born_two_foreign_parents + :dom_born_one_foreign_parent + :dom_born) |>
                            transform(foreign_background = :foreign_born + :dom_born_two_foreign_parents) |>
                            transform(percent_foreign_background = round.(broadcast(/, :foreign_background, :totalborn)*100, digits = 1))

    domestic_foreign_born_df = df_pre

    domestic_foreign_bornnow_df = domestic_foreign_born_df[nrow(domestic_foreign_born_df), :]

    return domestic_foreign_born_df, domestic_foreign_bornnow_df
end

function population_age()
    ages_url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/BefolkningR1860N"

    ages_json = JSON.parse("""{
                      "query": [
                        {
                          "code": "Alder",
                          "selection": {
                            "filter": "vs:Ålder1årL",
                            "values": [
                              "0",
                              "1",
                              "2",
                              "3",
                              "4",
                              "5",
                              "6",
                              "7",
                              "8",
                              "9",
                              "10",
                              "11",
                              "12",
                              "13",
                              "14",
                              "15",
                              "16",
                              "17",
                              "18",
                              "19",
                              "20",
                              "21",
                              "22",
                              "23",
                              "24",
                              "25",
                              "26",
                              "27",
                              "28",
                              "29",
                              "30",
                              "31",
                              "32",
                              "33",
                              "34",
                              "35",
                              "36",
                              "37",
                              "38",
                              "39",
                              "40",
                              "41",
                              "42",
                              "43",
                              "44",
                              "45",
                              "46",
                              "47",
                              "48",
                              "49",
                              "50",
                              "51",
                              "52",
                              "53",
                              "54",
                              "55",
                              "56",
                              "57",
                              "58",
                              "59",
                              "60",
                              "61",
                              "62",
                              "63",
                              "64",
                              "65",
                              "66",
                              "67",
                              "68",
                              "69",
                              "70",
                              "71",
                              "72",
                              "73",
                              "74",
                              "75",
                              "76",
                              "77",
                              "78",
                              "79",
                              "80",
                              "81",
                              "82",
                              "83",
                              "84",
                              "85",
                              "86",
                              "87",
                              "88",
                              "89",
                              "90",
                              "91",
                              "92",
                              "93",
                              "94",
                              "95",
                              "96",
                              "97",
                              "98",
                              "99",
                              "100",
                              "101",
                              "102",
                              "103",
                              "104",
                              "105",
                              "106",
                              "107",
                              "108",
                              "109",
                              "110+"
                            ]
                          }
                        },
                        {
                          "code": "Kon",
                          "selection": {
                            "filter": "item",
                            "values": [
                              "1",
                              "2"
                            ]
                          }
                        }
                      ],
                      "response": {
                        "format": "json"
                      }
                    }""")

    raw_df = SCB_API_pull(ages_url, ages_json)

    new_colnames = [:age, :year, :male_ages, :female_ages]

    df_pre = @linq raw_df |> unstack(:kön, :Folkmängd) |>
                                rename!(new_colnames)

    df_pre.age = (x -> x == "110+" ? "110" : x).(df_pre.age)

    # Change type to Int64
    for col in new_colnames
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    ages_df = @linq df_pre |> sort!(:age) |> transform(total_ages = :male_ages + :female_ages)

    max_year = maximum(ages_df.year)
    agesnow_df = @linq ages_df |> where(:year .== max_year)

    return ages_df, agesnow_df
end

function education_level()
    edu_url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/UF/UF0506/Utbildning"

    edu_json = JSON.parse("""{
      "query": [
        {
          "code": "Alder",
          "selection": {
            "filter": "agg:Ålder10år16-74",
            "values": [
              "25-34",
              "35-44",
              "45-54",
              "55-64",
              "65-74"
            ]
          }
        },
        {
          "code": "UtbildningsNiva",
          "selection": {
            "filter": "item",
            "values": [
              "1",
              "2",
              "3",
              "4",
              "5",
              "6",
              "7",
              "US"
            ]
          }
        }
      ],
      "response": {
        "format": "json"
      }
    }""")

    raw_df = SCB_API_pull(edu_url, edu_json)

    new_colnames = [:agegroup, :edu_code, :year, :count]

    df_pre = @linq raw_df |> rename!(new_colnames)

    # How does the below work?
    # 1. .(raw_df.utbildningsnivå) functions as the basis for the function. The . broadcasts (loops through each element of raw_df.utbildningsnivå to x at the start of the code.
    # 1. x -> assigns a value to x based on the condition before the ? (whose value comes from raw_df.utbildningsnivå). The value to be assigned is specified after the ?.
    # 2. The colon : sets up the next condition check.
    # 3. The first raw_df.utbildningsnivå on the last line specifies that if none of the conditions above are met, set the current broadcast value.

    df_pre.edu_level = (x -> x == "1" ? "Förgymnasial utbildning kortare än 9 år" :
                                x == "2" ? "Förgymnasial utbildning, 9 år" :
                                x == "3" ? "Gymnasial utbildning, högst 2 år" :
                                x == "4" ? "Gymnasial utbildning, 3 år" :
                                x == "5" ? "Eftergymnasial utbildning, mindre än 3 år" :
                                x == "6" ? "Eftergymnasial utbildning, 3 år eller mer" :
                                x == "7" ? "Forskarutbildning" :
                                x == "US" ? "Uppgift om utbildningsnivå saknar" :
                                 x).(df_pre.edu_code)

     df_pre.edu_labels = (x -> x == "1" ? "Förgymn. < 9 år" :
                                 x == "2" ? "Förgymn. 9 år" :
                                 x == "3" ? "Gymn. 2 år" :
                                 x == "4" ? "Gymn. 3 år" :
                                 x == "5" ? "Eftergymn. < 3 år" :
                                 x == "6" ? "Eftergymn. >= 3 år" :
                                 x == "7" ? "Forskarutb." :
                                 x == "US" ? "Uppgift saknas" :
                                  x).(df_pre.edu_code)

    # Change type to Int64
    for col in new_colnames[3:length(new_colnames)]
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    for col in 1:2
        df_pre[!, col] = map(x->convert(String, x), df_pre[!, col])
    end

    edu_level_df = df_pre

    max_year = maximum(edu_level_df.year)
    edu_levelnow_df = @linq edu_level_df |> where(:year .== max_year)

    return edu_level_df, edu_levelnow_df
end

function income()
    income_url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/HE/HE0110/HE0110A/SamForvInk2"

    income_json = JSON.parse("""{
                  "query": [
                    {
                      "code": "Kon",
                      "selection": {
                        "filter": "item",
                        "values": [
                          "1",
                          "2",
                          "1+2"
                        ]
                      }
                    },
                    {
                      "code": "Alder",
                      "selection": {
                        "filter": "item",
                        "values": [
                          "tot20+"
                        ]
                      }
                    },
                    {
                      "code": "Inkomstklass",
                      "selection": {
                        "filter": "item",
                        "values": [
                          "0",
                          "1-19",
                          "20-39",
                          "40-59",
                          "60-79",
                          "80-99",
                          "100-119",
                          "120-139",
                          "140-159",
                          "160-179",
                          "180-199",
                          "200-219",
                          "220-239",
                          "240-259",
                          "260-279",
                          "280-299",
                          "300-319",
                          "320-339",
                          "340-359",
                          "360-379",
                          "380-399",
                          "400-499",
                          "500-599",
                          "600-799",
                          "800-999",
                          "1000+"
                        ]
                      }
                    },
                    {
                      "code": "ContentsCode",
                      "selection": {
                        "filter": "item",
                        "values": [
                          "HE0110K3"
                        ]
                      }
                    }
                  ],
                  "response": {
                    "format": "json"
                  }
                }""")

    raw_df = SCB_API_pull(income_url, income_json)

    unique_income = unique(raw_df.inkomstklass)

    order_income = DataFrame(categorical(raw_df.inkomstklass, levels = unique_income))

    raw_df = hcat(raw_df, order_income)

    new_colnames = [:income, :level, :year, :male_income, :female_income, :total_income]

    df_pre = @linq raw_df |> unstack(:kön, Symbol("Antal personer")) |> select!([2, 4, 3, 6, 7, 8]) |> rename!(new_colnames) |> sort!(:level)

    # Change type to Int64
    for col in new_colnames[3:length(new_colnames)]
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    for col in 1:1
        df_pre[!, col] = map(x->convert(String, x), df_pre[!, col])
    end


    income_df = df_pre

    max_year = maximum(income_df.year)
    incomenow_df = @linq income_df |> where(:year .== max_year)

    return income_df, incomenow_df
end

function housing_form()
    housing_url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/HE/HE0111/HushallT31"

    housing_json = JSON.parse("""{
                      "query": [
                        {
                          "code": "Boendeform",
                          "selection": {
                            "filter": "item",
                            "values": [
                              "SMAG",
                              "SMBO",
                              "SMHY0",
                              "FBBO",
                              "FBHY0",
                              "SPBO",
                              "OB",
                              "ÖVRIGT"
                            ]
                          }
                        },
                        {
                          "code": "Kon",
                          "selection": {
                            "filter": "item",
                            "values": [
                              "1",
                              "2",
                              "4"
                            ]
                          }
                        }
                      ],
                      "response": {
                        "format": "json"
                      }
                    }""")

    raw_df = SCB_API_pull(housing_url, housing_json)

    unique_housing = unique(raw_df.boendeform)

    order_housing = DataFrame(categorical(raw_df.boendeform, levels = unique_housing))

    raw_df = hcat(raw_df, order_housing)

    new_colnames = [:housing_form, :age, :level, :year, :male_housing, :female_housing, :total_housing]

    df_pre = @linq raw_df |> unstack(:kön, Symbol("Antal personer")) |>
                                select!([1, 2, 4, 3, 6, 7, 8]) |>
                                rename!(new_colnames)

    df_pre.age = (x -> x == "90+" ? "90" : x).(df_pre.age)

    # Change type to Int64
    for col in new_colnames[4:length(new_colnames)]
        df_pre[!, col] = map(x->parse(Int64, x), df_pre[!, col])
    end

    for col in 1:1
        df_pre[!, col] = map(x->convert(String, x), df_pre[!, col])
    end

    df_pre.housing_labels = (x -> x == "FBBO" ? "Flerbostadshus, bostadsrätt" :
                                x == "FBHY0" ? "Flerbostadshus, hyresrätt" :
                                x == "OB" ? "Uppgift saknas" :
                                x == "SMAG" ? "Småhus, äganderätt" :
                                x == "SMBO" ? "Småhus, bostadsrätt" :
                                x == "SMHY0" ? "Småhus, hyresrätt" :
                                x == "SPBO" ? "Specialbostad" :
                                x == "ÖVRIGT" ? "Övrigt boende" :
                                 x).(df_pre.housing_form)

    housing_df = df_pre

    max_year = maximum(housing_df.year)
    housingnow_df = @linq housing_df |> where(:year .== max_year)

    return housing_df, housingnow_df
end

function housing_domfor()
    housing_domfor_url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/HE/HE0111/HushallT28"

    housing_domfor_json = JSON.parse("""{
                                          "query": [
                                            {
                                              "code": "UtlBakgrund",
                                              "selection": {
                                                "filter": "item",
                                                "values": [
                                                  "1",
                                                  "2"
                                                ]
                                              }
                                            },
                                            {
                                              "code": "Boendeform",
                                              "selection": {
                                                "filter": "item",
                                                "values": [
                                                  "SMAG",
                                                  "SMBO",
                                                  "SMHY0",
                                                  "FBBO",
                                                  "FBHY0",
                                                  "SPBO",
                                                  "OB",
                                                  "ÖVRIGT",
                                                  "TOT"
                                                ]
                                              }
                                            },
                                            {
                                              "code": "Alder",
                                              "selection": {
                                                "filter": "item",
                                                "values": [
                                                  "SAMAB"
                                                ]
                                              }
                                            },
                                            {
                                              "code": "Kon",
                                              "selection": {
                                                "filter": "item",
                                                "values": [
                                                  "1",
                                                  "2",
                                                  "4"
                                                ]
                                              }
                                            }
                                          ],
                                          "response": {
                                            "format": "px"
                                          }
                                        }""")

    raw_df = SCB_API_pull(housing_domfor_url, housing_domfor_json)
end

end # module
