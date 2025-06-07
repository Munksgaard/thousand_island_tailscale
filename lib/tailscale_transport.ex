defmodule TailscaleTransport do
  @moduledoc """
  Defines a `ThousandIsland.Transport` implementation based on a tailscale
  socket as provided by `:gen_tailscale`.

  Unless overridden, this module uses the following default options:

  ```elixir
  backlog: 1024,
  nodelay: true,
  send_timeout: 30_000,
  send_timeout_close: true,
  reuseaddr: true
  ```

  The following options are required for the proper operation of Thousand Island
  and cannot be overridden:

  ```elixir
  mode: :binary,
  active: false
  ```
  """

  @type options() :: [:gen_tailscale.listen_option()]
  @type listener_socket() :: :inet.socket()
  @type socket() :: :inet.socket()

  @behaviour ThousandIsland.Transport

  @hardcoded_options [mode: :binary, active: false]

  @impl ThousandIsland.Transport
  @spec listen(:inet.port_number(), [:inet.inet_backend() | :gen_tailscale.listen_option()]) ::
          ThousandIsland.Transport.on_listen()
  def listen(port, user_options) do
    default_options = [
      backlog: 1024,
      nodelay: true,
      send_timeout: 30_000,
      send_timeout_close: true,
      reuseaddr: true
    ]

    # We can't use Keyword functions here because :gen_tailscale accepts non-keyword style options
    resolved_options =
      Enum.uniq_by(
        @hardcoded_options ++ user_options ++ default_options,
        fn
          {key, _} when is_atom(key) -> key
          key when is_atom(key) -> key
        end
      )

    # `inet_backend`, if present, needs to be the first option
    sorted_options =
      Enum.sort(resolved_options, fn
        _, {:inet_backend, _} -> false
        _, _ -> true
      end)

    :gen_tailscale.listen(port, sorted_options)
  end

  @impl ThousandIsland.Transport
  @spec accept(listener_socket()) :: ThousandIsland.Transport.on_accept()
  def accept(listener_socket) do
    :gen_tailscale.accept(listener_socket)
  end

  @impl ThousandIsland.Transport
  @spec handshake(socket()) :: ThousandIsland.Transport.on_handshake()
  def handshake(socket) do
    {:ok, socket}
  end

  @impl ThousandIsland.Transport
  @spec upgrade(socket(), options()) :: ThousandIsland.Transport.on_upgrade()
  def upgrade(_, _), do: {:error, :unsupported_upgrade}

  @impl ThousandIsland.Transport
  @spec controlling_process(socket(), pid()) :: ThousandIsland.Transport.on_controlling_process()
  def controlling_process(socket, pid) do
    :gen_tailscale.controlling_process(socket, pid)
  end

  @impl ThousandIsland.Transport
  @spec recv(socket(), non_neg_integer(), timeout()) :: ThousandIsland.Transport.on_recv()
  def recv(socket, length, timeout) do
    :gen_tailscale.recv(socket, length, timeout)
  end

  @impl ThousandIsland.Transport
  @spec send(socket(), iodata()) :: ThousandIsland.Transport.on_send()
  def send(socket, data) do
    :gen_tailscale.send(socket, data)
  end

  @impl ThousandIsland.Transport
  @spec sendfile(
          socket(),
          filename :: String.t(),
          offset :: non_neg_integer(),
          length :: non_neg_integer()
        ) :: ThousandIsland.Transport.on_sendfile()
  def sendfile(socket, filename, offset, length) do
    case :file.open(filename, [:raw]) do
      {:ok, fd} ->
        try do
          :file.sendfile(fd, socket, offset, length, [])
        after
          :file.close(fd)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl ThousandIsland.Transport
  @spec getopts(socket(), ThousandIsland.Transport.socket_get_options()) ::
          ThousandIsland.Transport.on_getopts()
  def getopts(socket, options) do
    :gen_tailscale_socket.getopts(socket, options)
  end

  @impl ThousandIsland.Transport
  @spec setopts(socket(), ThousandIsland.Transport.socket_set_options()) ::
          ThousandIsland.Transport.on_setopts()
  def setopts(socket, options) do
    :gen_tailscale_socket.setopts(socket, options)
  end

  @impl ThousandIsland.Transport
  @spec shutdown(socket(), ThousandIsland.Transport.way()) ::
          ThousandIsland.Transport.on_shutdown()
  def shutdown(socket, way) do
    :gen_tailscale.shutdown(socket, way)
  end

  @impl ThousandIsland.Transport
  @spec close(socket() | listener_socket()) :: :ok
  def close(socket) do
    :gen_tailscale.close(socket)
  end

  @impl ThousandIsland.Transport
  @spec sockname(socket() | listener_socket()) :: ThousandIsland.Transport.on_sockname()
  def sockname(socket) do
    :gen_tailscale_socket.sockname(socket)
  end

  @impl ThousandIsland.Transport
  @spec peername(socket()) :: ThousandIsland.Transport.on_peername()
  def peername(socket) do
    :gen_tailscale_socket.peername(socket)
  end

  @impl ThousandIsland.Transport
  @spec peercert(socket()) :: ThousandIsland.Transport.on_peercert()
  def peercert(_socket) do
    {:error, :not_secure}
  end

  @impl ThousandIsland.Transport
  @spec secure?() :: false
  def secure? do
    false
  end

  @impl ThousandIsland.Transport
  @spec getstat(socket()) :: ThousandIsland.Transport.socket_stats()
  def getstat(socket) do
    :gen_tailscale_socket.getstat(socket, :inet.stats())
  end

  @impl ThousandIsland.Transport
  @spec negotiated_protocol(socket()) :: ThousandIsland.Transport.on_negotiated_protocol()
  def negotiated_protocol(_socket), do: {:error, :protocol_not_negotiated}

  @impl ThousandIsland.Transport
  @spec connection_information(socket()) :: ThousandIsland.Transport.on_connection_information()
  def connection_information(_socket), do: {:error, :not_secure}
end
