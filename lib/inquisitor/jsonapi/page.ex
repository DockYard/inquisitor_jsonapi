defmodule Inquisitor.JsonApi.Page do
  @moduledoc """
  Inquisitor query handlers for JSON API page

  [JSON API Spec](http://jsonapi.org/format/#fetching-pagination)

  #### Usage

  `use` the module *after* the `Inquisitor` module:

      defmodule MyApp do
        use Inquisitor
        use Inquisitor.JsonApi.Page

        ...
      end
  """

  require Inquisitor
  import Ecto.Query

  defmacro __using__(_opts) do
    quote do
      import Inquisitor.JsonApi.Page, only: [page_data: 3]

      def build_query(query, "page", pages, context) do
        build_page_query(query, pages, context)
      end

      @before_compile Inquisitor.JsonApi.Page
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: true do
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

  @doc """
  Calculate pagination data from query

  Will result in a map:

      %{ number: current_page_number, size: page_size, total: numer_of_all_pages, count: number_of_entries }

  Example:
      data = page_data(query, repo, params)
  """
  def page_data(query, repo, %{"page" => %{"number" => number, "size" => size}} = _params) do
    build_page_data(query, repo, typecast(number), typecast(size))
  end
  def page_data(query, repo,  %{"page" => %{"offset" => offset, "limit" => limit}} = _params) do
    build_page_data(query, repo, typecast(offset), typecast(limit))
  end

  defp build_page_data(query, repo, number, size) do
    count = calculate_count(query, repo)
    total = calculate_total(count, size)

    %{number: number, size: size, total: total, count: count}
  end

  defp calculate_count(query, repo) do
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

  defp calculate_total(count, size) do
    (count / size) |> Float.ceil() |> round()
  end

  defp typecast(integer) when is_integer(integer), do: integer
  defp typecast(integer) when is_binary(integer) do
    String.to_integer(integer)
  end

  @doc false
  def offset_and_limit(query, [offset: offset, limit: limit]) do
    query
    |> Ecto.Query.offset(^offset)
    |> Ecto.Query.limit(^limit)
  end

  @doc false
  def typecast_as_integer(integer) when is_binary(integer) do
    String.to_integer(integer)
  end
  def typecast_as_integer(integer), do: integer
end
