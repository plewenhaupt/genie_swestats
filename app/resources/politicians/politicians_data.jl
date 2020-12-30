using DataFrames,
        DataFramesMeta,
        HTTP,
        JSON,
        JSONTables

# Get JSON file
URL = "http://data.riksdagen.se/personlista/?iid=&fnamn=&enamn=&f_ar=&kn=&parti=&valkrets=&rdlstatus=&org=&utformat=json&sort=sorteringsnamn&sortorder=asc&termlista="
r = HTTP.get(URL)
println(r.status)

# Parse JSON to df
json_string = String(r.body)
json = JSON.Parser.parse(json_string)

person = json["personlista"]["person"]

df = reduce(vcat, DataFrame.(person))

df_age = @linq df |>
        groupby([:fodd_ar, :kon]) |> combine(nrow => :count) |>
        sort(:fodd_ar)

df_age.fodd_ar = map(x->parse(Int64, x), df_age.fodd_ar)
