defmodule Inspector do

  def vars(args) when args != nil do
    inspectVarsPath = System.get_env "INSPECT_VARS"
    if inspectVarsPath != nil && inspectVarsPath != "" do
      json = args |> Jason.encode!
      varsPath = String.replace inspectVarsPath, "\\", "/"
      if String.contains?(varsPath, "/") do
        dir = varsPath |> Path.dirname
        dir |> File.mkdir_p!
      end
      File.write varsPath, json
    end
  end

  def dump(obj) when obj != nil do
    json = obj |> Jason.encode! |> Jason.Formatter.pretty_print
    String.replace json, "\"", ""
  end

  def print_dump(obj) when obj != nil do
    IO.puts obj |> dump
  end

  def to_list_map(rows) when is_list(rows) do
    rows |> Jason.encode! |> Jason.decode!
  end

  def all_keys(rows) when is_list(rows) do
    Enum.reduce(rows, [], fn(row, acc) ->
      Enum.reduce(Map.keys(row), acc, fn(k, keys) ->
        if !Enum.member?(acc, k), do: [k | keys], else: keys
      end)
    end) |> Enum.reverse
  end

  def dump_table(rows, keys \\ []) when is_list(rows) do
    map_rows = rows |> to_list_map
    keys     = if Enum.empty?(keys), do: rows |> all_keys, else: keys

    col_sizes = Enum.reduce(keys, %{}, fn(k, map) ->
      max_len = Enum.reduce(map_rows, String.length("#{k}"), fn(row, acc_max) ->
        case Map.fetch(row, "#{k}") do
          {:ok, col} -> max(String.length("#{col}"), acc_max)
          :error -> acc_max
        end
      end)
      Map.put map, k, max_len
    end)

    col_sizes_length = col_sizes |> Enum.count
    row_width = (col_sizes |> Map.values |> Enum.sum) +
      (col_sizes_length * 2) +
      (col_sizes_length + 1)

    dashes = String.duplicate "-", row_width - 2
    sb = [
      "+#{dashes}+",

      Enum.reduce(keys, "|", fn (k, s) ->
        s <> align_center("#{k}", col_sizes[k], " ") <> "|"
      end),

      "|#{dashes}|",

      Enum.reduce(map_rows, [], fn (row, acc) ->
        [Enum.reduce(keys, "|", fn (k, s) ->
          s <> align_auto(row["#{k}"], col_sizes[k], " ") <> "|"
        end) | acc] |> Enum.reverse
      end),

      "+#{dashes}+",
    ] |> List.flatten

    Enum.join sb, "\n"
  end

  def print_dump_table(rows, keys \\ []) when is_list(rows) do
    IO.puts rows |> dump_table(keys)
  end

  def align_left(str, len, pad) do
    if len >= 0 do
      a_len = len + 1 - String.length(str)
      if a_len > 0, do: "#{pad}#{str}#{String.duplicate(pad,a_len)}", else: ""
    else
      ""
    end
  end

  def align_center(str, len, pad) do
    if len >= 0 do
      str = if str == nil, do: "", else: str
      n_len = str |> String.length
      half = (len / 2) - (n_len / 2)   |> floor
      odds = rem(n_len,2) - rem(len,2) |> abs
      "#{String.duplicate(pad, half + 1)}#{str}#{String.duplicate(pad, half + 1 + odds)}"
    else
      ""
    end
  end

  def align_right(str, len, pad) do
    if len >= 0 do
      a_len = len + 1 - String.length(str)
      if a_len > 0, do: "#{String.duplicate(pad,a_len)}#{str}#{pad}", else: ""
    else
      ""
    end
  end

  def align_auto(obj, len, pad) do
    str = "#{obj}"
    if String.length(str) <= len do
      if is_number(obj), do: align_right(str, len, pad), else: align_left(str, len, pad)
    else
      str
    end
  end

end
