defmodule UnusedTest do
  use ExUnit.Case
  doctest Unused
  @moduletag timeout: 6000000
  test "greets the world" do
    assert Unused.look("../platform_v2")
  end
end
