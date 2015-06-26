defmodule Gameoflife do
  use Application

  def start(_type, _args) do
    Gameoflife.Supervisor.start_link
  end
end
