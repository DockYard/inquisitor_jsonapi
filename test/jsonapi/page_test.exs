defmodule Inquisitor.JsonApi.PageTest do
  use Inquisitor.JsonApi.TestCase

  defmodule NoOp do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Page
  end

  test "supports `page[number]` and `page[size]`" do
    q = NoOp.build_query(User, %{"page" => %{"number" => "1", "size" => "10"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 0]}
  end

  test "supports `page[offset]` and `page[limit]`" do
    q = NoOp.build_query(User, %{"page" => %{"offset" => "1", "limit" => "10"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 1]}
  end
end
