defmodule Inquisitor.JsonApi.Page do
  require Inquisitor
  import Ecto.Query

  defmodule Functions do
    def page_data(query, repo, %{"page" => %{"number" => number, "size" => size}}) do
      {query, %{number: typecast(number), size: typecast(size), total: total(query, repo)}}
    end
    def page_data(query, repo,  %{"page" => %{"offset" => offset, "limit" => limit}}) do
      {query, %{number: typecast(offset), size: typecast(limit), total: total(query, repo)}}
    end

    defp total(query, repo) do
      query
      |> exclude(:offset)
      |> exclude(:limit)
      |> exclude(:preload)
      |> exclude(:select)
      |> exclude(:order_by)
      |> subquery()
      |> select(count("*"))
      |> repo.one()
      |> Kernel.||(0)
    end

    defp typecast(integer) when is_integer(integer), do: integer
    defp typecast(integer) when is_binary(integer) do
      String.to_integer(integer)
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Inquisitor.JsonApi.Page.Functions

      def build_query(query, "page", pages, context) do
        build_page_query(query, pages, context)
      end

      @before_compile Inquisitor.JsonApi.Page
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build_page_query(query, %{"number" => number, "size" => size}, _context) do
        number = Inquisitor.JsonApi.Page.typecast_as_integer(number)
        size   = Inquisitor.JsonApi.Page.typecast_as_integer(size)

        offset = (number - 1) * size

        Inquisitor.JsonApi.Page.offset_and_limit(query, offset: offset, limit: size)
      end
      def build_page_query(query, %{"offset" => offset, "limit" => limit}, _context) do
        Inquisitor.JsonApi.Page.offset_and_limit(query, offset: offset, limit: limit)
      end
      def build_page_query(query, _pages, _context), do: query

      defoverridable [build_page_query: 3]
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
