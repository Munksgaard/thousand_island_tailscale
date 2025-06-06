defmodule ThousandIslandTailscale.Plug do
  @moduledoc """
  A Phoenix plug that extracts Tailscale user information from the connection.
  """

  import Plug.Conn
  require Logger

  @behaviour Plug

  @impl Plug
  defn init(_opts) do
    %{}
  end

  @impl Plug
  def call(conn, _opts) do
    case extract_tailscale_user_info(conn) do
      {:ok, {ip, user_info}} ->
        conn
        |> assign(:tailscale_user, user_info)
        |> assign(:tailscale_ip, ip)

      {:error, _reason} ->
        send_resp(conn, :internal_server_error, "")
    end
  end

  defp extract_tailscale_user_info(conn) do
    with {:ok, socket} <- extract_gen_tailscale_socket(conn),
         {:ok, remote_ip} <- get_remote_ip(socket),
         {:ok, {address, _proxy_cred, local_api_cred}} <-
           :gen_tailscale_socket.start_loopback(socket),
         {:ok, user_info} <- fetch_user_info(address, local_api_cred, remote_ip) do
      {:ok, {remote_ip, user_info}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_gen_tailscale_socket(%Plug.Conn{adapter: {adapter_module, adapter_data}}) do
    case adapter_module do
      Bandit.Adapter ->
        case adapter_data do
          %{transport: %{socket: %{socket: socket}}} ->
            {:ok, socket}

          _ ->
            {:error, :no_socket_in_adapter}
        end

      _ ->
        {:error, :unsupported_adapter}
    end
  end

  defp get_remote_ip(socket) do
    case :gen_tailscale_socket.getremoteaddr(socket) do
      {:ok, ip} ->
        {:ok, ip}

      {:error, reason} ->
        {:error, {:getremoteaddr_failed, reason}}
    end
  end

  defp fetch_user_info(loopback_addr, local_api_cred, ip_addr) do
    # Create basic auth header
    auth = Base.encode64(":#{local_api_cred}")

    headers = [
      {"Authorization", "Basic #{auth}"},
      {"Host", loopback_addr},
      {"Sec-Tailscale", "localapi"}
    ]

    case Req.get(
           base_url: "http://#{loopback_addr}",
           headers: headers,
           url: "/localapi/v0/whois?addr=#{ip_addr}"
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end
end
