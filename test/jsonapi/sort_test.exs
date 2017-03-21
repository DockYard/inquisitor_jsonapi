defmodule Inquisitor.JsonApi.SortTest do
  use Inquisitor.JsonApi.TestCase

  @conn %Plug.Conn{}

  defmodule Base do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Sort
  end

  test "sort age ascending" do
    q = Base.build_query(User, @conn, %{"sort" => "age"})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 ORDER BY u0."age"}, []}
  end

  test "sort age decending" do
    q = Base.build_query(User, @conn, %{"sort" => "-age"})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 ORDER BY u0."age" DESC}, []}
  end

  test "sort on multiple fields" do
    q = Base.build_query(User, @conn, %{"sort" => "-age,name"})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 ORDER BY u0."age" DESC, u0."name"}, []}
  end
end
