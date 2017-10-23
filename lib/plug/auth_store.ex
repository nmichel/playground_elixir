defmodule Tuto.Auth.Store do
  import Plug.Conn
  import Plug.Session.Store
  
  @type filename :: binary

  @spec init(Plug.opts) :: filename
  def init(opts) do
    filename = Keyword.fetch!(opts, :file)
  end

  @spec get(Plug.Conn.t, Plug.Session.Store.cookie, filename) :: {Plug.Session.Store.sid, Plug.Session.Store.session}
  def get(conn, cookie, filename) do
    sessions = load_file(filename)
    session = sessions["sessions"][cookie]
    if session != nil do
      {cookie, session}
    else
      {nil, %{}}
    end
  end

  @spec put(Plug.Conn.t, Plug.Session.Store.sid, any, filename) :: Plug.Session.Store.cookie
  def put(conn, nil, session, filename) do
    %{"next" => id, "sessions" => sessions} = load_file(filename)
    sessions = Map.put(sessions, id, session)
    write_file(%{"next" => id+1, "sessions" => sessions}, filename)
    "#{id}"
  end

  def put(conn, sid, session, filename) do
    sessions_data = %{:sessions => sessions} = load_file(filename)
    sessions = Map.put(sessions, sid, session)
    write_file(%{sessions_data | "sessions" => sessions}, filename)
    sid
  end

  @spec delete(Plug.Conn.t, Plug.Session.Store.sid, filename) :: :ok
  def delete(conn, sid, filename) do
    sessions_data = %{sessions: sessions} = load_file(filename)
    sessions = Map.drop(sessions, [sid])
    write_file(%{sessions_data | "sessions" => sessions}, filename)
  end

  defp load_file(filename) do
    try do
      {:ok, data} = File.read(filename)
      {:ok, sessions} = Poison.decode(data)
      sessions
    rescue
      _ ->
        %{"next" =>  0, "sessions" => %{}}
    end
  end

  defp write_file(sessions, filename) do
    {:ok, data} = Poison.encode(sessions)
    File.write!(filename, data)
  end
end
