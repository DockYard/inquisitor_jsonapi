defmodule Inquisitor.JsonApi.PageTest do
  use Inquisitor.JsonApi.TestCase

  @context %{}

  defmodule Base do
    require Ecto.Query
    use Inquisitor
    use Inquisitor.JsonApi.Page
  end

  test "supports `page[number]` and `page[size]`" do
    q = Base.build_query(User, @context, %{"page" => %{"number" => "1", "size" => "10"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 0]}
  end

  test "supports `page[number]` and `page[size]` with multiple pages" do
    q = Base.build_query(User, @context, %{"page" => %{"number" => "2", "size" => "10"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 10]}
  end

  test "supports `page[number]` and `page[size]` non-strings" do
    q = Base.build_query(User, @context, %{"page" => %{"number" => 1, "size" => 10}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 0]}
  end

  test "supports `page[offset]` and `page[limit]`" do
    q = Base.build_query(User, @context, %{"page" => %{"offset" => "1", "limit" => "10"}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 1]}

    q = Base.build_query(User, @context, %{"page" => %{"offset" => 1, "limit" => 10}})
    assert to_sql(q) == {~s{SELECT u0."id", u0."name", u0."age" FROM "users" AS u0 LIMIT $1 OFFSET $2}, [10, 1]}
  end

  test "calculates page data with `page[number]` and `page[size]`" do
    Repo.insert!(%User{name: "Foo", age: 1})
    Repo.insert!(%User{name: "Bar", age: 2})
    Repo.insert!(%User{name: "Baz", age: 3})
    Repo.insert!(%User{name: "Qux", age: 4})

    params = %{"page" => %{"number" => "1", "size" => "2"}}

    {_query, page_data} =
      User
      |> Base.build_query(@context, params)
      |> Inquisitor.JsonApi.Page.Functions.page_data(Repo, params)

    expected = %{
      number: 1,
      size: 2,
      total: 2,
      count: 4
    }

    assert expected == page_data
  end

  test "calculates page data with `page[offset]` and `page[limit]`" do
    Repo.insert!(%User{name: "Foo", age: 1})
    Repo.insert!(%User{name: "Bar", age: 2})
    Repo.insert!(%User{name: "Baz", age: 3})

    params = %{"page" => %{"offset" => "0", "limit" => "2"}}

    {_query, page_data} =
      User
      |> Base.build_query(@context, params)
      |> Inquisitor.JsonApi.Page.Functions.page_data(Repo, params)

    expected = %{
      number: 0,
      size: 2,
      total: 2,
      count: 3
    }

    assert expected == page_data
  end
end
