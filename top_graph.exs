#!/usr/bin/env elixir


if length(System.argv()) < 1 do
  IO.puts(:stderr, "Usage #{:filename.basename(__ENV__.file())} <toplog.txt>")
  exit 1
end
[filename] = System.argv()

{plotdata, timepoints} = TopUtil.parse_file(filename)
IO.inspect(timepoints)



ds = plotdata |> DataSet.make_from_top() |> DataSet.n_highest_max(2, 3)

pids = ds |> Enum.map(fn x ->
  x |> Enum.at(0) |> (fn y -> Enum.at(y,1) <> " (" <> Enum.at(y,0) <> ")" end).()
end)
cpu = ds |> Enum.map(fn x -> x |> Enum.map(fn y -> y |> Enum.at(2) end) end)
_mem = ds |> Enum.map(fn x -> x |> Enum.map(fn y -> y |> Enum.at(3) end) end)

plots = (for pid <- pids, do: ["-", :using, to_charlist("1:2"), :title, pid])

dataset = cpu |> Enum.map(fn x -> 
  Enum.zip(timepoints, x)
end)


{:ok, _cmd} = Gnuplot.plot([
  [:set, :title, "rand uniform vs normal"],
  [:set, :key, :left, :top],
  [:set, :terminal, "wxt"],
  ~w(set format x "%H:%M:%S" timedate)a,
  [:set, :xdata, :time],
  [:set, :style, :data, :lines],
  ~w(set timefmt "%H:%M:%S")a,
  ~w(set grid xtics ytics)a,
  Gnuplot.plots(plots)
  ], dataset)

