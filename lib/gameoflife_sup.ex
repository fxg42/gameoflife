defmodule Gameoflife.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    create_world(20, 20)
  end

  def step do
    cells = Supervisor.which_children(__MODULE__) |> Enum.map(&(elem(&1, 1)))
    cells |> Enum.map(&GenServer.call(&1, :prepare))
    cells |> Enum.map(&GenServer.call(&1, :commit)) |> print
    step()
  end

  def init(:ok) do
    children = [
      worker(Gameoflife.Cell, [], restart: :permanent)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  defp create_world(width, height) do
    seed_random
    for x <- 1..width, y <- 1..height do
      starts_alive? = :random.uniform(55) == 1
      Supervisor.start_child(__MODULE__, [x, y, starts_alive?, [name: :"#{x},#{y}"]])
    end
  end

  defp seed_random do
    <<a::32, b::32, c::32>> = :crypto.rand_bytes(12)
    :random.seed({a, b, c})
  end

  defp print(values) do
    board = (for _ <- 1..20, do: '                              ') |> Enum.to_list

    Enum.reduce(values, board, fn {x, y, alive?}, acc ->
      List.update_at(acc, y, fn row -> List.update_at(row, x, fn _ ->
        if alive? do
          '#'
        else
          ' '
        end
      end) end)
    end)
    |> Enum.each(&IO.puts/1)
  end
end
