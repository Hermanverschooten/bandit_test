defmodule BanditTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BanditTestWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BanditTest.PubSub},
      # Start Finch
      {Finch, name: BanditTest.Finch},
      # Start the Endpoint (http/https)
      BanditTestWeb.Endpoint
      # Start a worker by calling: BanditTest.Worker.start_link(arg)
      # {BanditTest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BanditTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BanditTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
