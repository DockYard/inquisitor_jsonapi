defmodule Inquisitor.JsonApi.Sort do
  @moduledoc """
  Inquisitor query handlers for JSON API sorting

  [JSON API Spec](http://jsonapi.org/format/#fetching-sorting)

  #### Usage

  `use` the module *after* the `Inquisitor` module:

      defmodule MyApp do
        use Inquisitor
        use Inquisitor.JsonApi.Sort

        ...
      end
  """
  require Inquisitor

  defmacro __using__(_opts) do
    quote do
      def build_query(query, "sort", sorts, _context) do
        sorts =
          sorts
          |> String.split(",")
          |> Enum.map(fn
            <<"-", column::binary>> -> {:desc, String.to_existing_atom(column)}
            column -> {:asc, String.to_existing_atom(column)}
          end)

        Ecto.Query.order_by(query, ^sorts)
      end
    end
  end
end
