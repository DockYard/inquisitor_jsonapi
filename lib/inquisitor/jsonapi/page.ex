defmodule Inquisitor.JsonApi.Page do
  require Inquisitor
  require Ecto.Query

  defmacro __using__(_opts) do
    quote do
      def build_query(query, [{"page", pages} | tail]) do
        query
        |> build_query_page(pages)
        |> build_query(tail)
      end

      @before_compile Inquisitor.JsonApi.Page
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build_query_page(query, %{"number" => number, "size" => size}) do
        number =
          case number do
            number when is_binary(number) -> String.to_integer(number)
            number when is_integer(number) -> number
          end
        number = number - 1

        Inquisitor.JsonApi.Page.offset_and_limit(query, offset: number, limit: size)
      end
      def build_query_page(query, %{"offset" => offset, "limit" => limit}) do
        Inquisitor.JsonApi.Page.offset_and_limit(query, offset: offset, limit: limit)
      end
      def build_query_page(query, _), do: query

      defoverridable [build_query_page: 2]
    end
  end

  def offset_and_limit(query, [offset: offset, limit: limit]) do
    query
    |> Ecto.Query.offset(^offset)
    |> Ecto.Query.limit(^limit)
  end
end
