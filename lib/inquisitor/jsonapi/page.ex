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
        number = Inquisitor.JsonApi.Page.typecast_as_integer(number)
        size   = Inquisitor.JsonApi.Page.typecast_as_integer(size)

        offset = (number - 1) * size

        Inquisitor.JsonApi.Page.offset_and_limit(query, offset: offset, limit: size)
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

  def typecast_as_integer(integer) when is_binary(integer) do
    String.to_integer(integer)
  end
  def typecast_as_integer(integer), do: integer
end
