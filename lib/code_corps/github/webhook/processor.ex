defmodule CodeCorps.GitHub.Webhook.Processor do
  @moduledoc """
  Serves as a point of entry to process GitHub webhooks.

  Can process them synchronously or asynchronously.
  """

  alias CodeCorps.GitHub.Webhook.Handler

  @doc """
  Used to process a Github webhook event in an async manner.

  Receives the event JSON as the only parameter.

  Returns `{:ok, pid}`
  """
  def process_async(type, payload) do
    Task.Supervisor.start_child(:webhook_processor, fn -> process(type, payload) end)
  end

  defdelegate process(type, payload), to: EventHandler, as: :handle
end
