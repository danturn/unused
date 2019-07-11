defmodule FunctionsTest do
  use ExUnit.Case
  alias Unused.Functions
  @moduletag timeout: 6_000_000
  test "gree the world" do
    Functions.get("../platform")
  end
end
