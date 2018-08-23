defmodule Unused.GrepTest do
  use ExUnit.Case, async: true
  alias Unused.Grep

  @text1 "text1"
  @text2 "text2"
  @file_name "test_file.txt"
  @file_name2 "test_file2.txt"

  setup do
    File.rm @file_name
    File.rm @file_name2
    File.write(@file_name, @text1 <> " " <> @text2)
    File.write(@file_name2, @text1 <> " " <> @text2)
    on_exit fn -> 
      File.rm @file_name
      File.rm @file_name2
    end
  end

  describe "find/2" do
    test "returns not found for terms not in any files" do
      assert %{~s|garbage not found| => [{@file_name, :not_found}]} == Grep.find(@file_name, ["garbage not found"])
    end

    test "returns found for all terms in files" do
      assert %{
        @text1 => [{@file_name2, [@text1]}, {@file_name, [@text1]}], 
        @text2 => [{@file_name2, [@text2]}, {@file_name, [@text2]}]} == Grep.find("test_file*", [@text1, @text2])
    end
  end

  test "format_results" do
    results = 
      [
        [{"search1", "file1", :not_found}],
        [{"search1", "file2", :not_found}],
        [{"search1", "file3", :found}]
      ]

    assert %{"search1" => [{"file1", :not_found}, {"file2", :not_found}, {"file3", :found}]} == Grep.format_results(results)
  end
end
