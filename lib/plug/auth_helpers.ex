defmodule Tuto.Auth.Helpers do
  import Plug.Conn
  
  def authenticate(conn, login, password, opts) do
      source = Keyword.fetch!(opts, :source)
      case source.check_and_load(login, password) do
          {:ok, user} ->
              {:ok, login(conn, user)}
          {:error, :credentials} ->
              {:error, :unauthorized, conn}
          {:error, :not_found} ->
              {:error, :not_found, conn} 
      end
  end

  def delete_session(conn) do
      configure_session(conn, drop: true)
  end

  defp login(conn, user) do
      conn
      |> put_session(:user_id, user.id)
      |> assign(:current_user, user)
  end
end
