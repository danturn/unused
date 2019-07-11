defmodule UnusedTest do
  use ExUnit.Case
  doctest Unused
  @moduletag timeout: 6_000_000
  test "greets the world" do
    assert Unused.look("../platform")
  end
end
