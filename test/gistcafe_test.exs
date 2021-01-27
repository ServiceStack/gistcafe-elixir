defmodule InspectorTest do
  use ExUnit.Case
  doctest Inspector

  @args [
    %{ "za" => 1,    "b" => "foo" },
    %{ "za" => 2.1,  "b" => "foobar" },
    %{ "za" => 3.21, "b" => "foobarbaz" },
  ]

  test "Inspector.vars" do
    Inspector.vars @args
  end

  test "dump" do
    IO.puts ""
    Inspector.print_dump @args
    IO.puts ""
  end

  test "dump_table" do
    IO.puts ""
    Inspector.print_dump_table @args
    Inspector.print_dump_table @args, [:za, :b]
    IO.puts ""
  end

  test "github api" do
    org_name = "elixir-lang"

    "https://api.github.com/orgs/#{org_name}/repos"
    |> HTTPoison.get([ "User-Agent": "gist.cafe" ])
    |> case do
        {:ok, %{body: raw_body, status_code: code}} -> {code, raw_body}
        {:error, %{reason: reason}} -> {:error, reason}
      end
    |> (fn {_, body} ->
      org_repos = Jason.decode!(body)
      |> Enum.map(fn (x) -> %{
        name:        x["name"],
        description: x["description"],
        url:         x["url"],
        lang:        x["language"],
        watchers:    x["watchers"],
        forks:       x["forks"]
      } end)
      |> Enum.sort_by(&(&1.watchers))
      |> Enum.reverse

      IO.puts "Top 3 #{org_name} GitHub Repos:"
      Inspector.print_dump org_repos |> Enum.take(3)

      IO.puts "\nTop 10 #{org_name} GitHub Repos:"
      Inspector.print_dump_table Enum.take(org_repos, 7), [:name, :lang, :watchers, :forks]
    end).()

  end

end
