[gist.cafe](https://gist.cafe) utils for Elixir

## Installation

This package can be installed by adding `gistcafe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gistcafe, "~> 0.1.0"}
  ]
end
```

## Usage

Simple Usage Example:

```elixir
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
```

Which outputs:

```
Top 3 elixir-lang GitHub Repos:
[
  {
    description: Elixir is a dynamic, functional language designed for building scalable and maintainable applications,
    forks: 2606,
    lang: Elixir,
    name: elixir,
    url: https://api.github.com/repos/elixir-lang/elixir,
    watchers: 18083
  },
  {
    description: Producer and consumer actors with back-pressure for Elixir,
    forks: 160,
    lang: Elixir,
    name: gen_stage,
    url: https://api.github.com/repos/elixir-lang/gen_stage,
    watchers: 1048
  },
  {
    description: ExDoc produces HTML and EPUB documentation for Elixir projects,
    forks: 207,
    lang: Elixir,
    name: ex_doc,
    url: https://api.github.com/repos/elixir-lang/ex_doc,
    watchers: 991
  }
]

Top 10 elixir-lang GitHub Repos:
+--------------------------------------------------------+
|          name          |    lang    | watchers | forks |
|--------------------------------------------------------|
| elixir_make            | Elixir     |      110 |    25 |
| elixir-lang.github.com | CSS        |      288 |   746 |
| gen_stage              | Elixir     |     1048 |   160 |
| elixir                 | Elixir     |    18083 |  2606 |
| ex_doc                 | Elixir     |      991 |   207 |
| registry               | Elixir     |      140 |     6 |
| elixir-windows-setup   | Inno Setup |       38 |     9 |
+--------------------------------------------------------+
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ServiceStack/gistcafe-elixir.
