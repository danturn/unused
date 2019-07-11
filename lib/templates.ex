defmodule Unused.Templates do
  alias Unused.Grep

  def get(project_path) do
    templates =
      project_path
      |> Path.join("/lib/**/{*.html.eex}")
      |> Path.wildcard()
      |> extract_template_names
      |> Enum.map(fn {path, template} -> {:template, path, ~r|\b#{template}\b|} end)

    # TODO only look in lib?
    unused_templates =
      project_path
      |> Grep.find(templates)
      |> not_found_only()

    rootnames =
      Enum.map(unused_templates, fn x ->
        {:templates, x, ~r|\b#{Path.basename(x, ".html.eex")}\b|}
      end)

    project_path
    |> Path.join("/**/router.ex")
    |> Grep.find(rootnames)
    |> not_found_only()
  end

  defp extract_template_names(files) do
    Enum.map(files, fn path -> {path, Path.basename(path, ".eex")} end)
  end

  def not_found_only(list) do
    list
    |> Enum.flat_map(fn {_, files} ->
      Enum.reject(files, fn {_, occurences} ->
        Enum.any?(occurences, fn {_, occurence} -> occurence != [] end)
      end)
    end)
    |> Enum.map(fn {file, _} -> file end)
  end
end
