defmodule Inquisitor.JsonApi.Sort do
  require Inquisitor

  defmacro __using__(_opts) do
    quote do
      def build_query(query, [{"sort", sorts} | tail]) do
        sorts =
          sorts
          |> String.split(",")
          |> Enum.map(fn
            <<"-", column::binary>> -> {:desc, String.to_existing_atom(column)}
            column -> {:asc, String.to_existing_atom(column)}
          end)

        query
        |> Ecto.Query.order_by(^sorts)
        |> build_query(tail)
      end
    end
  end
end
