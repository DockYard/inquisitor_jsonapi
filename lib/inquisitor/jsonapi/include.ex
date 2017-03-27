defmodule Inquisitor.JsonApi.Include do
  @moduledoc """
  Inquisitor query handlers for JSON API includes

  [JSON API Spec](http://jsonapi.org/format/#fetching-includes)

  #### Usage

  `use` the module *after* the `Inquisitor` module:

      defmodule MyApp do
        use Inquisitor
        use Inquisitor.JsonApi.Include

        ...
      end

  this module allow you to decide how to you want to handle include params.
  For example you may query your API with the following URL:

      https://example.com/posts?include=tags,author

  You can use `build_include_query/3` to define matchers:

      def build_include_query(query, include, _context) do
        Ecto.Query.preload(query, ^String.to_existing_atom(include))
      end

  #### Relationship paths

  The value for an include could be dot-seperated to indicate a nesting:

      author.profile

  If you want to parse and `preload` this relationship properly:

      def build_incude_query(query, include, _context) do
        preload = Inquisitor.JsonApi.Include.preload_parser(include)
        Ecto.Query.preload(query, preload)
      end

  For the given include of `author.profile` the result of `Inquisitor.JsonApi.Include.preload_parser/1`
  would be `[author: :profile]`. The parser can handle infinite depths:

      "foo.bar.baz.qux"
      |> preload_parser()

      > [foo: [bar: [baz: :qux]]]

  #### Security

  This module is secure by default. Meaning that you must opt-in to handle the include params.
  Otherwise they are ignored by the query builder.

  If you would like to limit the values to act upon use a `guard`:

      @include_whitelist ~w(tags author)
      def build_include_query(query, include, _context) when include in @include_whitelist do
        Ecto.Query.preload(query, ^String.to_existing_atom(include))
      end
  """
  require Inquisitor

  defmacro __using__(_opts) do
    quote do
      def build_query(query, "include", includes, context) do
        includes
        |> String.split(",")
        |> Enum.reduce(query, fn(include, query) ->
          build_include_query(query, include, context)
        end)
      end

      @before_compile Inquisitor.JsonApi.Include
    end
  end

  defmacro __before_compile__(_env) do
    quote generated: true do
      def build_include_query(query, include, context), do: query
      defoverridable [build_include_query: 3]
    end
  end

  @doc """
  Parse path segments into nested keyword list

  Example:
      "foo.bar.baz.qux"
      |> preload_parser()

      > [foo: [bar: [baz: :qux]]]
  """
  def preload_parser(path) do
    path
    |> String.split(".")
    |> build_segments()
  end

  defp build_segments([segment | []]),
    do: String.to_existing_atom(segment)
  defp build_segments([segment | segments]) do
    [{String.to_existing_atom(segment), build_segments(segments)}]
  end
end
