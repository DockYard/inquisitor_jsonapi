defmodule Inquisitor.JsonApi.Sort do
  require Inquisitor

  defmacro __using__(_opts) do
    quote do
      def build_query(query, "sort", sorts, _conn) do
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
