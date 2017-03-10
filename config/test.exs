use Mix.Config

config :inquisitor_jsonapi, Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "inquisitor_jsonapi_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  size: 1
