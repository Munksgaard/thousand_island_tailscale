defmodule LocalAPI do
  def whois(ip_addr) do
    Req.get!("http:///localapi/v0/whois?addr=#{ip_addr}",
      unix_socket: "/var/run/tailscale/tailscaled.sock",
      headers: [host: "local-tailscaled.sock"]
    )
  end
end

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    dbg(socket, limit: :infinity, printable_limit: :infinity, structs: false)

    if socket.private.connect_info != %{} do
      {Bandit.Adapter, adapter} = socket.private.connect_info.adapter
      dbg(adapter.transport.socket.socket)
      :gen_tailscale_socket.info(adapter.transport.socket.socket) |> dbg
    end

    # if socket.transport_pid do
    #   dbg(:sys.get_state(socket.transport_pid))
    # end

    {:ok, assign(socket, count: 0)}
  end

  def render(assigns) do
    ~H"""
    <span><%= @count %></span>
    <button phx-click="inc">+</button>
    <button phx-click="dec">-</button>

    <style type="text/css">
      body { padding: 1em; }
    </style>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end
end

PhoenixPlayground.start(
  live: DemoLive,
  live_reload: false,
  endpoint_options: [
    url: [host: "counter"],
    http: [
      ip: :any,
      port: 2000,
      thousand_island_options: [
        transport_module: ThousandIslandTailscale,
        transport_options: [hostname: "counter"]
      ]
    ]
  ],
  open_browser: false
)
