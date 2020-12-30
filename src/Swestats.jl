module Swestats

using Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = Swestats))

  include(joinpath("..", "genie.jl"))

  Base.eval(Main, :(const Genie = Swestats.Genie))
  Base.eval(Main, :(using Genie))
end; main()

end
