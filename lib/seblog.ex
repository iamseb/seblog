defmodule Seblog do
  use Application

  @event_manager_name Seblog.EventManager

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(GenEvent, [[name: @event_manager_name]]),
      # Start the endpoint when the application starts
      supervisor(Seblog.Endpoint, []),
      # Start the Ecto repository
      supervisor(Seblog.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Seblog.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Seblog.Supervisor]
    result = Supervisor.start_link(children, opts)

    GenEvent.add_mon_handler(Seblog.EventManager, Seblog.NotifyHandler, [])

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Seblog.Endpoint.config_change(changed, removed)
    :ok
  end
end
