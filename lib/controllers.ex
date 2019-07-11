defmodule Unused.Controllers do

  alias Unused.Grep
  @function_finder ~r{(?<=def )[^(|^ |^,]*}
  @module_finder ~r{(?<=defmodule )[^ ]*}


  def get(project_path) do
    lib_path =
      project_path
      |> Path.join("/lib/*web/controllers/**/*.ex")

    %{function_definitions: %{all: functions}, modules: %{all: modules}} =
      Grep.find(lib_path, [{:function_definitions, :all, @function_finder}, {:modules, :all, @module_finder}])

    functions = functions |> Map.new()

    controllers_with_functions =
      Enum.map(modules, fn {file_name, [module_name| _]} -> {module_name, file_name,functions[file_name]} end)

    used_controller_funs=
      :os.cmd('cd #{project_path} && mix phx.routes')
      |> to_string
      |> String.split("\n")
      |> Enum.map(fn route ->
        String.split(route, " ", trim: true)
      end)
      |> Enum.reject(fn segments -> Enum.count(segments) != 5 end)
      |> Enum.map(&Enum.drop(&1, 3))
      |> Enum.group_by(fn [module, _] -> module end)
      |> Enum.map(fn {module, funs} -> {module, Enum.map(funs, fn [_, fun] -> fun end)} end)
      |> Map.new()


    controllers_with_functions
    |> Enum.reduce(%{unused_controllers: [], unused_actions: []}, fn {controller_module, file, functions}, acc ->
      case used_controller_funs[controller_module] do
        nil ->
          Map.update!(acc, :unused_controllers, fn x -> [{controller_module, file} | x] end)
            #          IO.puts "CONTROLLER #{controller_module} at path: #{file} IS COMPLETELY UNUSED"

        used_functions ->
          case Enum.filter(functions, fn function -> ":#{function}" not in used_functions end) do
            [] ->
              acc
            unused_functions ->
              Map.update!(acc, :unused_actions, fn x -> [{unused_functions, controller_module} | x] end)
              #              IO.puts
          end
      end
    end)
  end
end
