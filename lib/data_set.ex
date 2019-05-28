defmodule DataSet do
  @moduledoc """
  This module specifies certain utility functions over a datastructure like:
  [
    [[pid_1, name_1, cpu_11, mem_11], [pid_1, name_1, cpu_12, mem_12], ...],
    [[pid_2, name_2, cpu_21, mem_21], [pid_2, name_2, cpu_22, mem_22], ...],
    .
    .
    .
    [[pid_n, name_n, cpu_n1, mem_n1], [pid_n, name_n, cpu_n2, mem_n2], ...],
  ]
  """
  def make_from_top(plotdata) do
    measures = 0..(length(hd(plotdata))-1)
    Enum.reduce(measures, [], fn(x, acc) ->
      entries_of_x = plotdata |> Enum.map(fn(entry) ->
        Enum.at(entry, x)
      end)
      [entries_of_x|acc]
    end)
  end

  def low_pass_filter(dataset, mesurement_index, pass_value) do
    dataset |> Enum.filter(fn x ->
      x |> Enum.all?(fn y ->
        {f,_} = Float.parse(Enum.at(y, mesurement_index))
        f > pass_value
      end)
    end)
  end

  defp filter_by_pids(dataset, pidlist) do
    dataset |> Enum.filter(fn x ->
      hd(hd(x)) in pidlist
    end)
  end

  defp join_with_pid(y, record_line) do
    { Enum.at(hd(record_line), 0), y }
  end

  defp sort_desc(tup_list, sort_by_index) do
      tup_list |> Enum.sort_by(fn tup -> elem(tup, sort_by_index) end, &>/2)
  end

  def n_highest_avg(dataset, measurement_index, n) do
    top_pids = dataset |> Enum.map(fn x ->
      x |> Enum.reduce(0, fn y, acc ->
        {f,_} = Enum.at(y, measurement_index) |> Float.parse()
        f + acc
      end)
        |> (fn y -> y / length(x) end).()
        |> join_with_pid(x)
    end)
      |> sort_desc(1)
      |> Enum.slice(0..n) |> Enum.map(fn {pid,_} -> pid end)

    dataset |> filter_by_pids(top_pids)
  end

  def n_highest_max(dataset, measurement_index, n) do
    top_pids = dataset |> Enum.map(fn x ->
       x |> Enum.reduce(0, fn y, acc ->
        {f, _} = Enum.at(y, measurement_index) |> Float.parse()
        cond do
          f > acc -> f
          true -> acc
        end
      end)
        |> join_with_pid(x)
    end)
      |> sort_desc(1)
      |> Enum.slice(0..n) |> Enum.map(fn {pid,_} -> pid end)

    dataset |> filter_by_pids(top_pids)
  end


end
