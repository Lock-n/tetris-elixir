# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tetris_ui, TetrisUiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "a8d4uaz25a7Denjr3D3Ypj690Zr4YClVMbGJOZ0LuGjkMcoFxo7+HYf15A+xNikl",
  render_errors: [view: TetrisUiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TetrisUi.PubSub,
  live_view: [signing_salt: "p8sQ9iZr"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
