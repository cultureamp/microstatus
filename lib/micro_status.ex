defmodule MicroStatus do
  @moduledoc """
  A server that returns the status of the application
  """

  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, fetch_version(Mix.env), name: name)
  end

  def fetch_version(:dev) do
    ~s({ "commit_sha": "#{local_git_revision()}", "version": null })
  end

  def fetch_version(:prod) do
    path = Application.get_env(:micro_status, :app_name)
    |> :code.priv_dir
    |> Path.join("VERSION")
    case(File.read(path)) do
      {:ok, ref} -> ref
      {:error, _} -> nil
    end
  end

  def fetch_version(_) do
    fetch_version(:dev)
  end

  def version(name) do
    GenServer.call(name, :version)
  end

  defp local_git_revision do
    {rev, _exit_status} = System.cmd("git", ["rev-parse", "HEAD"])
    rev |> String.strip
  end

  def handle_call(:version, _, status_json) do
    {:reply, status_json, status_json}
  end
end
