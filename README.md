# ElixirChess

ElixirChess is going to be a set of modules for processing chess games and validating moves. At the moment it only contains a Board module for converting a FEN position to a special board tuple and back to a FEN position. More to come.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add elixirchess to your list of dependencies in `mix.exs`:

        def deps do
          [{:elixirchess, "~> 0.0.1"}]
        end

  2. Ensure elixirchess is started before your application:

        def application do
          [applications: [:elixirchess]]
        end
