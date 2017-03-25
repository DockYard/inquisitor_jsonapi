Logger.configure(level: :info)
ExUnit.start()

{:ok, _pid} = Repo.start_link()
