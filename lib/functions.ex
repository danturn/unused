defmodule Unused.Functions do
  alias Unused.Grep

  @function_finder ~r{(?<=def )[^(|^ |^,]*}
  @module_finder ~r{(?<=defmodule )[^ ]*}

  def get(project_path) do
    lib_path =
      project_path
      |> Path.join("/lib/**/*.*")

    just_functions =
      lib_path
      |> Grep.find([
        {:function_definitions, :all, @function_finder},
        {:modules, :all, @module_finder}
      ])
      |> functions_with_modules()
      |> Enum.flat_map(fn {module, file, functions} ->
        aliased_module_name = module |> String.split(".") |> Enum.reverse() |> hd()

        Enum.map(functions, fn function ->
          regex = Regex.escape(function)
          {:function_calls, {module, file, function}, ~r|\b#{aliased_module_name}.#{regex}|}
        end)
      end)

    %{function_calls: calls} = Grep.find(lib_path, just_functions)

    unused(calls)
  end

  defp unused(data) do
    data
    |> Enum.filter(fn {{_, file, _}, occurences} ->
      occurences
      |> Enum.reject(fn {occ_file, _} -> occ_file == file end)
      |> Enum.all?(fn {_, occurence} -> occurence == [] end)
    end)
    |> Enum.map(fn {{module, _, function}, _} -> {function, module} end)
    |> Enum.sort_by(fn {_, module} -> module end)
  end

  def functions_with_modules(%{function_definitions: %{all: functions}, modules: %{all: modules}}) do
    functions = functions |> reject_empty_occurences() |> Map.new()

    modules
    |> reject_empty_occurences()
    |> Enum.map(fn {file, [module_name | _]} -> {module_name, file, functions[file]} end)
    |> Enum.reject(fn {_, _, functions} -> functions == nil end)
  end

  defp reject_empty_occurences(list) do
    list |> Enum.reject(fn {_, occurences} -> occurences == [] end)
  end
end
