defmodule Gameoflife.Supervisor do
  use Supervisor

  def start_link({width, height}, mode) do
    result = Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    create_world(width, height, mode)
    result
  end

  def step(event_manager) do
    cells = Supervisor.which_children(__MODULE__) |> Enum.map(&(elem(&1, 1)))
    cells |> Enum.map(&GenServer.call(&1, :prepare))
    cell_values = cells |> Enum.map(&GenServer.call(&1, :commit))

    GenEvent.notify(event_manager, {:cells, cell_values})
    step(event_manager)
  end

  def init(:ok) do
    children = [
      worker(Gameoflife.Cell, [], restart: :permanent)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  defp create_world(width, height, mode) do
    seed_random
    for x <- 1..width, y <- 1..height do
      starts_alive? = if mode == :random, do: :random.uniform(100) < 50, else: false
      Supervisor.start_child(__MODULE__, [{x, y, starts_alive?, width, height}, [name: :"#{x},#{y}"]])
    end
  end

  defp seed_random do
    <<a::32, b::32, c::32>> = :crypto.rand_bytes(12)
    :random.seed({a, b, c})
  end
end
