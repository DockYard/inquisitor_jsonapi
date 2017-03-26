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

  This module allows you to decide how you want to handle filter key/value params.
  For example you may query your API with the following URL:

      https://example.com/posts?filter[foo]=bar&filter[baz]=qux

  You can use `build_filter_query/4` to define matchers:

      def build_filter_query(query, "foo", value, _conn) do
        Ecto.Query.where(query, [r], r.foo == ^value)
      end

      def build_filter_query(query, "baz", value, _conn) do
        Ecto.Query.where(query, [r], r.baz > ^value)
      end

  #### General key/value matcher

  You may want a handler that simply queries on key/value pairs. Use the following:

      def build_filter_query(query, key, value, _conn) do
        Ecto.Query.where(query, [r], Ecto.Query.API.field(r, ^String.to_existing_atom(key)) == ^value)
      end

  #### Security

  This module is secure by default. Meaning that you must opt-in to handle the filter params.
  Otherwise they are ignored by the query builder.

  If you would like to limit the values to act upon use a `guard`:

      @filter_whitelist ~w(name title)
      def build_filter_query(query, key, value, _conn) where key in @filter_whitelist do
        Ecto.Query.where(query, [r], Ecto.Query.API.field(r, ^String.to_existing_atom(key)) == ^value)
      end
  """
  require Inquisitor

  defmacro __using__(_opts) do
    quote do
      def build_query(query, "filter", filters, context) do
        Enum.reduce(filters, query, fn({key, value}, query) ->
          build_filter_query(query, key, value, context)
        end)
      end

      @before_compile Inquisitor.JsonApi.Filter
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build_filter_query(query, _key, _value, _context), do: query
      defoverridable [build_filter_query: 4]
    end
  end
end
