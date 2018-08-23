defmodule Unused do
  alias Unused.Templates
  
  def look(path) do
    info("Looking for unused templates as i'm sure you're incapable of tidying up after yourself")
    unused_templates = Templates.get(path)

    IO.puts "\nFinished looking!"
    if Enum.any?(unused_templates) do
      info("You absolute buffoon. You have the following unused template files:")
      Enum.each(unused_templates, &oopsie/1)
    else 
      success("Miraculously you don't have any useless cruft kicking around, you better get back to generating some")
    end
  end

  defp info(text) do
    IO.puts IO.ANSI.magenta() <> text <> IO.ANSI.reset()
  end

  defp success(text) do
    IO.puts IO.ANSI.green() <> text <> IO.ANSI.reset()
  end

  defp oopsie(text) do
    IO.puts IO.ANSI.red() <> text <> IO.ANSI.reset()
  end
end
