defmodule Inquisitor.JsonApi.FilterTest do
  use Inquisitor.JsonApi.TestCase

  @conn %Plug.Conn{}

  defmodule NoOp do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Filter
  end

  test "defaults to no-op by default when no filter handlers are defined" do
    q = NoOp.build_query(User, @conn, %{"filter" => %{"name" => "Brian"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0}, []}
  end

  defmodule Composed do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Filter

    def build_filter_query(query, "name", name, _conn) do
      Ecto.Query.where(query, [r], r.name == ^name)
    end

    def build_filter_query(query, "age", age, _conn) do
      Ecto.Query.where(query, [r], r.age == ^age)
    end
  end

  test "builds query with composed matchers" do
    q = Composed.build_query(User, @conn, %{"filter" => %{"name" => "Brian", "age" => "99"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 WHERE (u0."age" = $1) AND (u0."name" = $2)}, [99, "Brian"]}
  end
end
