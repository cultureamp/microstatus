# Status

The boilerplate code for status endpoints for microservices.

This was previously duplicated across all of Culture Amp's microservice repositories. Changes to how we display status information was becoming cumbersome, so it's now centralised in this repo.

## Installation

Add the dependency in `mix.exs`:

```
{:micro_status, path: "~/code/cultureamp/microstatus"},
```

Run:

```
mix deps.get
```

Tell `micro_status` what your application is called (in `config/config.exs`):

```elixir
config :micro_status, app_name: :your_app
```

Add a worker to the application (`lib/your_app.ex`):

```elixir
def start(_type, _args) do
  import Supervisor.Spec

  # Define workers and child supervisors to be supervised
  children = [
    supervisor(YourApp.Repo, []),
    supervisor(YourApp.Endpoint, []),
    worker(MicroStatus, []), # THIS LINE!!
  ]
  ...
```

Define a controller:

```
defmodule Waffle.StatusController do
  use YourApp.Web, :controller

  def index(conn, _params) do
    status = MicroStatus.version

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, status)
  end
end
```

Define a route (`web/router.ex` if Phoenix, or wherever routes are defined):

```elixir
get "/status", StatusController, :index

Boot your app, and see if a request to `/status` works. It should return something like:

```json
{
  "commit_sha": "eed50f13223a4ea45a1cd59e33f7868d086343e9",
  "version": null
}
```

If there's a `priv/VERSION` file, it will read the data from that. You can put whatever you want in this file, but you _must_ have at least a `commit_sha` and a `version`. This file is typically created during the deployment process of your application.

If there is no `priv/VERSION`, microstatus uses some :star:Git Magic™:star: to work out the current SHA and that's what it displays.


