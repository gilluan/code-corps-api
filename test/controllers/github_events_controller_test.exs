defmodule CodeCorps.GitHubEventsControllerTest do
  use CodeCorps.ConnCase

  setup do
    conn =
      %{build_conn() | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  defp wait_for_supervisor(), do: wait_for_children(:webhook_processor)

  # used to have the test wait for or the children of a supervisor to exit

  defp wait_for_children(supervisor_ref) do
    Task.Supervisor.children(supervisor_ref)
    |> Enum.each(&wait_for_child/1)
  end

  defp wait_for_child(pid) do
    # Wait until the pid is dead
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  defp for_event(conn, type) do
    conn |> put_req_header("X-GitHub-Event", type)
  end

  test "responds with 202 when the event will not be processed", %{conn: conn} do
    path = conn |> github_events_path(:create)
    assert conn |> post(path, %{}) |> response(202)

    wait_for_supervisor()
  end
end
