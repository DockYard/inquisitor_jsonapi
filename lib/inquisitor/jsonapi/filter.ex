defmodule Inquisitor.JsonApi.Filter do
  @moduledoc """
  Inquisitor query handlers for JSON API filters

  JSON API Spec: http://jsonapi.org/format/#fetching-filtering

  #### Usage

  `use` the module *after* the `Inquisitor` module:

      defmodule MyApp do
        use Inquisitor
        use Inquisitor.JsonApi.Filter

        ...
      end

  This module allows you to decide how you want to handle filter key/value parms.
  For example you may query your API with the following URL:

      https://example.com/posts?filter[foo]=bar&filter[baz]=qux

  You can use `build_filter_query/4` to define matchers:

      deffilter "foo", value do
        query
        |> Ecto.Query.where([r], r.foo == ^value)
      end

      deffilter "baz", value do
        query
        |> Ecto.Query.where([r], r.baz > ^value)
      end
  """
  require Inquisitor

  defmacro __using__(_opts) do
    quote do
      def build_query(query, "filter", filters, conn) do
        Enum.reduce(filters, query, fn({key, value}, query) ->
          build_filter_query(query, key, value, conn)
        end)
      end

      @before_compile Inquisitor.JsonApi.Filter
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build_filter_query(query, _key, _value, _conn), do: query
      defoverridable [build_filter_query: 4]
    end
  end
end
