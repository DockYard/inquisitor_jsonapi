defmodule Inquisitor.JsonApi.FilterTest do
  use Inquisitor.JsonApi.TestCase

  defmodule NoOp do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Filter
  end

  test "defaults to no-op by default when no filter handlers are defined" do
    q = NoOp.build_query(User, %{"filter" => %{"name" => "Brian"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0}, []}
  end

  defmodule Composed do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Filter

    deffilter "name", name do
      query
      |> Ecto.Query.where([r], r.name == ^name)
    end

    deffilter "age", age do
      query
      |> Ecto.Query.where([r], r.age == ^age)
    end
  end

  test "builds query with composed matchers" do
    q = Composed.build_query(User, %{"filter" => %{"name" => "Brian", "age" => "99"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 WHERE (u0."age" = $1) AND (u0."name" = $2)}, [99, "Brian"]}
  end
end
