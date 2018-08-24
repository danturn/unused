defmodule Unused.Functions do
  alias Unused.Grep

  @function_finder ~r{(?<=def )[^(|^ |^,]*}
  @module_finder ~r{(?<=defmodule )[^ ]*}

  def get(project_path) do
    lib_path = 
      project_path
      |> Path.join("/lib/**/*.ex")

    functions_with_modules = 
      lib_path
      |> Grep.find([{:functions, :all, @function_finder}, {:modules, :all, @module_finder}])
      |> functions_with_modules()

    just_functions = 
      functions_with_modules 
      |> Enum.flat_map(fn {module, functions} -> Enum.map(functions, fn function -> {:dont_know, {module, function}, ~r|\b#{function}\b|} end) end)
      |> Enum.uniq

    %{dont_know: data} = Grep.find(lib_path, just_functions)
    #
    end
  def unused(data) do
    IO.inspect data
    Enum.filter(data, fn {description, occurences} -> Enum.all?(occurences, fn {z, occurence} -> occurence == [];  end) end)
    |> Enum.map(fn {identifier, _} -> identifier end)
    |> IO.inspect
  end

  def functions_with_modules(%{functions: %{all: functions}, modules: %{all: modules}}) do
    functions = functions |> reject_empty_occurences() |> Map.new()

    modules 
    |> reject_empty_occurences()
    |> Enum.map(fn {file, [module_name]} -> {module_name, functions[file]} end)
    |> Enum.reject(fn {module, functions} -> functions == nil end)
    |> Map.new()
  end

  defp reject_empty_occurences(list) do
    list |> Enum.reject(fn {_, occurences} -> occurences == [] end)
  end

  defp aliased_functions(%{functions: %{all: functions}}) do
    Enum.flat_map(functions, fn {file, funs} ->
      module = 
        file
        |> Path.basename(".ex")
        |> Macro.camelize

      funs
      |> List.flatten()
      |> Enum.map(fn fun -> "#{module}.#{fun}" end)
    end)
  end
end
