defmodule Unused.Grep do
  alias Unused.Grep

  def find(path, patterns) do
    path =
      if File.dir?(path) do
        Path.join(path, "/**/{*.ex,*.exs,*.html.eex}")
      else
        path
      end

    path
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> start_searches(patterns)
    |> wait_for_results()
  end

  def start_searches(paths, patterns) do
    Enum.map(paths, &Task.async(Grep, :find_in_file, [&1, patterns]))
  end

  def wait_for_results(tasks) do
    # TODO progress? we can get a count then keep where we are in the acc
    Enum.reduce(tasks, [], fn task, acc ->
      #  IO.write(IO.ANSI.green() <> "." <> IO.ANSI.reset())
      collate_result(Task.await(task), acc)
    end)
    |> format_results()
  end

  def format_results(results) do
    results
    |> List.flatten()
    |> group_by_tag()
    |> group_by_pattern()
  end

  defp group_by_tag(results) do
    Enum.group_by(results, fn {tag, _, _, _} -> tag end, fn {_, pattern, file, result} ->
      {pattern, file, result}
    end)
  end

  defp group_by_pattern(results) do
    Map.new(results, fn {tag, matches} ->
      {tag,
       Enum.group_by(matches, fn {pattern, _, _} -> pattern end, fn {_, file, result} ->
         {file, result}
       end)}
    end)
  end

  defp collate_result({:ok, result}, acc), do: [result | acc]
  defp collate_result({:error, reason}, _), do: raise("Unable to read file: #{reason}")

  def find_in_file(path, patterns) do
    File.open(path, [:read], fn file ->
      lines = IO.read(file, :all)

      Enum.map(patterns, fn {tag, description, pattern} ->
        matches = Regex.scan(pattern, lines)
        {tag, description, path, List.flatten(matches)}
      end)
    end)
  end
end
