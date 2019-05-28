defmodule TopUtil do
  @moduledoc """
    Some utility functions for parsing top -b -n output
  """


  @doc """
  Returns the lines to whom the cb specifies that they are in the "common set"
  of each list in our list_of_lists
  """
  def intersect(list_of_lists, cb) do
    intersection = intersect(list_of_lists, [], cb)
    Enum.map(list_of_lists, fn(list) ->
      Enum.filter(list, fn(x) ->
        cb.(intersection, x)
      end)
    end)
  end
  defp intersect([], acc, _cb) do
    acc
  end
  defp intersect([head|tail], [], cb) do
    intersect(tail, head, cb)
  end
  defp intersect([head|tail], acc, cb) do
    newacc = Enum.filter(head, fn(x) ->
      cb.(acc, x)
    end)
    intersect(tail, newacc, cb)
  end


  defp ws_split(y) do
    Enum.map(y, fn x ->
      x |> String.trim() |> String.split(~r/\s+/)
    end)
  end

  @doc """
  Parse file of output of top -b -n X, and return a list datastructure
  """
  def parse_file(filename) do
    a = File.read!(filename)
    data = a |> String.split(~r/^top/m) |> tl
    # header
    _header = data |> Enum.map(fn d ->
      d |> String.split("\n") |> Enum.slice(6..6) |> ws_split()
    end)

    # plot data
    plotdata = data |> Enum.map(fn d ->
      d |> String.split("\n")
        |> Enum.slice(7..-1)
        |> Enum.filter(fn x -> x != "" end)
        |> ws_split()
        |> Enum.map(fn x -> [Enum.at(x, 0), Enum.at(x, 11), Enum.at(x, 8), Enum.at(x, 9)] end)
        |> Enum.sort_by(fn x -> Enum.at(x, 3) end, &>/2)
    end) |> intersect(fn(acc, x) ->
      pids = Enum.map(acc, fn(y) -> hd(y) end)
      hd(x) in pids
    end) |> Enum.map(fn x ->
        x |> Enum.sort_by(fn([pid,_,_,_]) -> pid end, &>/2)
    end)

    timepoints = data |> Enum.map(fn d ->
      d |> String.split("\n")
        |> Enum.slice(0..0)
        |> Enum.map(fn x ->
          x |> String.trim()
            |> String.split(~r/\s+/)
            |> Enum.at(1)
            #|> Time.from_iso8601()
        end) |> hd
    end)

    {plotdata, timepoints}
  end
end
