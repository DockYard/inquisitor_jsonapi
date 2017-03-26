# Default Query Scopes

You may have need for default query scopes. One pattern for achieving
this in Phoenix is to use a controller `plug`.

    defmodule MyApp.PostController do
      use MyApp.Web, :controller
      use Inquisitor.JsonApi

      plug :default_params, :index when action == :index

      def index(conn, params) do
        posts =
          Post
          |> build_query(conn, params)
          |> Repo.all()

        render(conn, data: posts)
      end

      defp default_params(conn, :index) do
        params = Map.put_new(conn.params, "sort", "-published_at")
        %{conn | params: params}
      end
    end

In the above example the `default_params/2` plug will allow us to modify
the inbound params map. We want to set a default `sort` value but not
overwrite if one is being requested. So we can use `Map.put_new/3` which
will add the key/value pair to the map only if it isn't already there.

We allow Inqusitor to handle the params, we just care about setting it
to our desired state before its handled.

You can use this pattern to set default params for all actions.
