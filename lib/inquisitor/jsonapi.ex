defmodule Inquisitor.JsonApi do
  @moduledoc """
  Container module for all Inquisitor.JsonApi modules

  `use` this module to opt-in to all modules:

  Before:

      defmodule MyApp do
        use Inquisitor
        use Inquisitor.JsonApi.Filter
        use Inquisitor.JsonApi.Include
        use Inquisitor.JsonApi.Page
        use Inquisitor.JsonApi.Sort

        ...
      end

  After:

      defmodule MyApp do
        use Inquisitor.JsonApi

        ...
      end
  """
  defmacro __using__(_opts) do
    quote do
      use Inquisitor
      use Inquisitor.JsonApi.Filter
      use Inquisitor.JsonApi.Include
      use Inquisitor.JsonApi.Page
      use Inquisitor.JsonApi.Sort
    end
  end
end
