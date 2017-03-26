defmodule Inquisitor.JsonApi.IncludeTest do
  use Inquisitor.JsonApi.TestCase

  @context %{}

  defmodule NoOp do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Include
  end

  test "defaults to no-op by default when no include handlers are defined" do
    q = NoOp.build_query(User, @context, %{"include" => "posts"})
    assert q == User
  end

  defmodule Composed do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Include

    def build_include_query(query, include, _context) do
      Ecto.Query.preload(query, ^String.to_atom(include))
    end
  end

  test "builds query with composed matchers" do
    q = Composed.build_query(User, @context, %{"include" => "posts"})
    assert q.preloads == [:posts]
  end

  test "preload parser" do
    parsed = Inquisitor.JsonApi.Include.preload_parser("foo.bar.baz.qux")
    assert parsed == [foo: [bar: [baz: :qux]]]

    parsed = Inquisitor.JsonApi.Include.preload_parser("foo")
    assert parsed == :foo
  end
end
