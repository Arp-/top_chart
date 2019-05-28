#!/usr/bin/env elixir

import Gnuplot

if length(System.argv()) < 1 do
  IO.puts(:stderr, "Usage #{:filename.basename(__ENV__.file())} <toplog.txt>")
  exit 1
end

{plotdata, timepoints} = TopUtil.parse_file("asd2.txt")
IO.inspect(timepoints)



ds = plotdata |> DataSet.make_from_top() |> DataSet.n_highest_max(2, 3)

pids = ds |> Enum.map(fn x ->
  x |> Enum.at(0) |> (fn y -> Enum.at(y,1) <> " (" <> Enum.at(y,0) <> ")" end).()
end)
cpu = ds |> Enum.map(fn x -> x |> Enum.map(fn y -> y |> Enum.at(2) end) end)
_mem = ds |> Enum.map(fn x -> x |> Enum.map(fn y -> y |> Enum.at(3) end) end)

#IO.inspect(pids, limit: :infinity)
#IO.inspect(cpu, limit: :infinity)

plots = for pid <- pids, do: ["-", :title, pid, :with, :lines]
dataset = cpu |> Enum.map(fn x -> Enum.zip(0..length(hd(cpu))-1, x) end)
#IO.inspect(dataset, limit: :infinity)


{:ok, _cmd} = Gnuplot.plot([
  [:set, :title, "rand uniform vs normal"],
  [:set, :key, :left, :top],
  [:set, :terminal, "wxt"],
  #[:set, :timefmt, "%H:%M:%S"],
  #[:set, :xtics, :format, "%H:%M:%S"],
  ~w(set grid xtics ytics)a,
  Gnuplot.plots(plots)
  ], dataset)
