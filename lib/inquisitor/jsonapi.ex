defmodule Inquisitor.JsonApi do
  defmacro __using__(_opts) do
    quote do
      use Inquisitor
      use Inquisitor.JsonApi.Filter
      use Inquisitor.JsonApi.Page
      use Inquisitor.JsonApi.Sort
    end
  end
end
