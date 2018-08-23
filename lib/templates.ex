defmodule Unused.Templates do
  alias Unused.Grep

  def get(path) do
    templates = 
      path
      |> Path.join("/**/{*.html.eex}")
      |> Path.wildcard()
      |> extract_template_names

    unused_templates = 
      path
      |> Grep.find(templates)
      |> not_found_only()

    rootnames = Enum.map(unused_templates, &Path.rootname/1)
    rootnames_to_paths = Map.new(unused_templates, &({Path.rootname(&1), &1}))

    rootnames_not_in_use = 
      path
      |> Path.join("/**/router.ex")
      |> Grep.find(rootnames)
      |> not_found_only()

    Enum.map(rootnames_not_in_use, &(rootnames_to_paths[&1]))
  end

  defp extract_template_names(files) do
    Enum.map(files, &Path.basename(&1, ".eex"))
  end

  defp not_found_only(list) do
    list
    |> Enum.reject(fn {_, occurences} -> Enum.any?(occurences, fn {_, occurence} -> occurence != :not_found end) end)
    |> Enum.map(fn {file, _} -> file end)
  end
end
