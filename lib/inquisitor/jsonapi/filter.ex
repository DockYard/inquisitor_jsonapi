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

  You can use the `deffilter/2` to define matchers:

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
      import Inquisitor.JsonApi.Filter

      def build_query(query, [{"filter", filters} | tail]) do
        filters = Map.to_list(filters)

        query
        |> build_query_filter(filters)
        |> build_query(tail)
      end

      @before_compile Inquisitor.JsonApi.Filter
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build_query_filter(query, []), do: query
      def build_query_filter(query, [{_field, _value} | filters]) do
        build_query_filter(query, filters)
      end

      defoverridable [build_query_filter: 2]
    end
  end

  Module.add_doc(__MODULE__, __ENV__.line + 2, :defmacro, {:deffilter, 2}, (quote do: [field, value]), """
  Define new query matcher for filters

  Filter query matcher macro, the `query` is automatically injected at compile-time for use in the block

  Usage

      deffilter "name", name do
        query
        |> Ecto.Query.where([r], r.name == ^name)
      end

  You can also use guards with the macro:

      deffilter attr, value when attr == "month" or attr == "year" do
        query
        |> Ecto.Query.where([e], fragment("date_part(?, ?) = ?", ^attr, e.inserted_at, type(^value, :integer)))
      end
  """)

  @doc false
  defmacro deffilter(key, value, [do: do_expr]) do
    do_expr = Macro.prewalk(do_expr, fn
      {:query, meta, nil} -> {:query, meta, __MODULE__}
      node -> node
    end)

    [value, when_expr] = case value do
      {:when, _meta, expr} -> expr
      value -> [value, true]
    end

    quote do
      def build_query_filter(query, [{unquote(key), unquote(value)} | tail]) when unquote(when_expr) do
        unquote(do_expr)
        |> build_query_filter(tail)
      end
    end
  end
end
