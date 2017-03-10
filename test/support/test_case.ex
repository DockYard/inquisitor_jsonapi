defmodule Inquisitor.JsonApi.TestCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import Inquisitor.JsonApi.TestCase
    end
  end

  def to_sql(query) do
    Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  end
end
