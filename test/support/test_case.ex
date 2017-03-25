defmodule Inquisitor.JsonApi.TestCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import Inquisitor.JsonApi.TestCase

      setup do
        Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      end
    end
  end

  def to_sql(query) do
    Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  end
end
