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
    Enum.map(paths, &(Task.async(Grep, :find_in_file, [&1, patterns])))
  end

  def wait_for_results(tasks) do
    #TODO progress? we can get a count then keep where we are in the acc
    Enum.reduce(tasks, [], fn (task, acc) -> 
      IO.write(IO.ANSI.green() <> "." <> IO.ANSI.reset())
      collate_result(Task.await(task), acc)
    end)
    |> format_results()
  end 

  def format_results(results) do
    results
    |> List.flatten
    |> Enum.group_by(fn {pattern, _, _} -> pattern end, fn {_, file, result} -> {file, result} end)
  end

  defp collate_result({:ok, result}, acc), do: [result | acc]
  defp collate_result({:error, reason}, _), do: raise "Unable to read file: #{reason}"

  def find_in_file(path, patterns) do
    File.open(path, [:read], fn(file) ->
      lines = IO.read(file, :all)

      Enum.map(patterns, fn pattern -> 
        case Regex.run(~r|\b#{pattern}\b|, lines) do
          nil -> {pattern, path, :not_found}
          matches -> {pattern, path, matches}
        end
      end)
    end)
  end
end
