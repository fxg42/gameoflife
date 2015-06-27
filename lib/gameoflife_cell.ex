defmodule Gameoflife.Cell do
  use GenServer

  defstruct x: nil, y: nil, alive?: nil, neighbours: [], will_be_alive?: nil

  def start_link(x, y, starts_alive?, width, height, opts) do
    GenServer.start_link(__MODULE__, [x, y, starts_alive?, width, height], opts)
  end

  def init([x, y, starts_alive?, width, height]) do
    {:ok, %Gameoflife.Cell{x: x, y: y, alive?: starts_alive?, neighbours: find_neighbours(x, y, width, height)}}
  end

  def handle_call(:alive?, _from, state) do
    {:reply, state.alive?, state}
  end

  def handle_call(:prepare, _from, state) do
    alive_neighbour_count = state.neighbours
    |> Enum.map(&Task.async(GenServer, :call, [&1, :alive?]))
    |> Enum.map(&Task.await/1)
    |> Enum.filter(&(&1))
    |> length

    {:reply, :ok, %{state | will_be_alive?: will_be_alive?(state.alive?, alive_neighbour_count) }}
  end

  def handle_call(:commit, _from, state) do
    {:reply, {state.x, state.y, state.alive?}, %{state | alive?: state.will_be_alive?}}
  end

  defp find_neighbours(x, y, width, height) do
    [
      {x-1, y-1},
      {x-1, y+0},
      {x-1, y+1},
      {x+0, y+1},
      {x+1, y+1},
      {x+1, y+0},
      {x+1, y-1},
      {x+0, y-1}
    ]
    |> Stream.map(fn {x, y} -> {wrap(x, width), wrap(y, height) } end)
    |> Stream.map(fn {x, y} -> :"#{x},#{y}" end)
    |> Enum.to_list()
  end

  defp wrap(pos, width) when pos == 0, do: width
  defp wrap(pos, width) when pos > width, do: 1
  defp wrap(pos, _width), do: pos

  defp will_be_alive?(false, 3), do: true
  defp will_be_alive?(_alive?, alive_neighbour_count) when alive_neighbour_count < 2, do: false
  defp will_be_alive?(_alive?, alive_neighbour_count) when alive_neighbour_count < 4, do: true
  defp will_be_alive?(_alive?, _alive_neighbour_count), do: false
end
