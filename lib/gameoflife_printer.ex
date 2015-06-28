defmodule Gameoflife.Printer do
  use GenEvent

  def init([dimensions]), do: {:ok, dimensions}

  def handle_event({:cells, cells}, dimensions) do
    print(cells, dimensions)
    {:ok, dimensions}
  end

  defp print(cells, {width, height}) do
    grid = (for _ <- 1..height, do: String.duplicate(" ", width) |> String.to_char_list) |> Enum.to_list
    IO.puts "---"
    cells |> Enum.reduce(grid, &update_grid/2) |> Enum.each(&IO.puts/1)
  end

  defp update_grid({col, row, alive?}, grid) do
    List.update_at(grid, row-1, fn row -> List.update_at(row, col-1, &update_col(&1, alive?)) end)
  end

  defp update_col(_curr, true), do: '#'
  defp update_col(_curr, false), do: ' '
end
