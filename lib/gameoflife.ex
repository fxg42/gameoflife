defmodule Gameoflife do
  use Application

  def start(_type, [dimensions]) do
    {:ok, event_manager} = GenEvent.start_link
    GenEvent.add_handler(event_manager, Gameoflife.Printer, [dimensions])

    {:ok, pid} = Gameoflife.Supervisor.start_link(dimensions)

    Gameoflife.Supervisor.step(event_manager)

    {:ok, pid}
  end
end
