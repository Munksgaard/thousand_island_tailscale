# TailscaleTransport

A transport for ThousandIsland that allows exposing services directly to your tailnet.

An example application can be found in [tschat](https://github.com/Munksgaard/tschat).

## Installation

The package can be installed by adding `tailscale_transport` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tailscale_transport, "~> 0.1.0"}
  ]
end
```

## Usage

In your `config/config.exs`, when defining your endpoint, specify that you want
to use the `TailscaleTransport` module as the transport module for
`ThousandIsland`:

```elixir
config :my_app, MyAppWeb.Endpoint,
  url: [host: "my-app"],
  adapter: Bandit.PhoenixAdapter,
  ...
  http: [
    thousand_island_options: [
      transport_module: TailscaleTransport,
      transport_options: [hostname: "my-app"]
    ]
  ]
```

Notice that you need to specify the same hostname in the `url` parameter and as
the `hostname` parameter to the `transport_options` option.
