defmodule CodeCorps.GitHubEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.GitHub.Webhook.Processor

  def create(conn, event_payload) do
    event_type = conn |> extract_event_type()
    case event_type |> check_support() do
      :supported ->
        Processor.process_async(event_type, event_payload)
        conn |> send_resp(200, "")
      :unsupported ->
        conn |> send_resp(202, "")
    end
  end

  defp check_support(_), do: :unsupported

  defp extract_event_type(%Plug.Conn{} = conn) do
    conn |> Plug.Conn.get_req_header("X-GitHub-Event")
  end
end
