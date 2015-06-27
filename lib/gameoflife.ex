defmodule Gameoflife do
  use Application

  def start(_type, [dimensions, mode]) do
    {:ok, event_manager} = GenEvent.start_link
    GenEvent.add_handler(event_manager, Gameoflife.Printer, [dimensions])

    {:ok, pid} = Gameoflife.Supervisor.start_link(dimensions, mode)

    if mode == :glider do
      GenServer.call(:"10,10", :live)
      GenServer.call(:"11,10", :live)
      GenServer.call(:"12,10", :live)
      GenServer.call(:"12,9", :live)
      GenServer.call(:"11,8", :live)
    end

    Gameoflife.Supervisor.step(event_manager)

    {:ok, pid}
  end
end
