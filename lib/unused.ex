defmodule Unused do
  alias Unused.Templates
  alias Unused.Functions
  alias Unused.Controllers

  def main([path]) do
    look(path)
  end

  def look(path) do
    templates(path)

    IO.puts(
      "--------------------------------------------------------------------------------------"
    )

    functions(path)

    IO.puts(
      "--------------------------------------------------------------------------------------"
    )

    controllers(path)
  end

  defp templates(path) do
    info("Looking for unused templates as i'm sure you're incapable of tidying up after yourself")
    unused_templates = Templates.get(path)

    if Enum.any?(unused_templates) do
      info("You absolute buffoon. You have the following unused template files:")
      Enum.each(unused_templates, &oopsie/1)
    else
      success(
        "Miraculously you don't have any useless cruft kicking around, you better get back to generating some"
      )
    end
  end

  defp functions(path) do
    info(
      "I'm pretty sure you've made loads of functions public and never used them... let me check"
    )

    unused_functions = Functions.get(path)

    if Enum.any?(unused_functions) do
      info("I knew it... here are the unused functions")

      Enum.each(unused_functions, fn {function, module} ->
        oopsie(~s|function: #{function} in module: #{module}|)
      end)
    else
      success(
        "Miraculously you don't have any useless cruft kicking around, you better get back to generating some"
      )
    end
  end

  defp controllers(path) do
    info("Looking for controllers and actions that arent called in the router...")
    unused = Controllers.get(path)

    if Enum.any?(unused.unused_controllers) do
      info("I knew it... here are the unused controllers")

      Enum.each(unused.unused_controllers, fn {module, file} ->
        oopsie(~s|#{module} at #{file} is not found|)
      end)
    end

    if Enum.any?(unused.unused_actions) do
      info("I knew it... here are the unused controller actions")

      Enum.each(unused.unused_actions, fn {unused_actions, module} ->
        oopsie(
          ~s|functions: [#{Enum.join(unused_actions, ", ")}] are not used on controller: #{module}|
        )
      end)
    end
  end

  defp info(text) do
    IO.puts(IO.ANSI.magenta() <> text <> IO.ANSI.reset())
  end

  defp success(text) do
    IO.puts(IO.ANSI.green() <> text <> IO.ANSI.reset())
  end

  defp oopsie(text) do
    IO.puts(IO.ANSI.red() <> text <> IO.ANSI.reset())
  end
end
