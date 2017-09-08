defmodule Mix.Tasks.Version.MajorTest do
  use ExUnit.Case
  alias Mix.Tasks.Version.Major

  test "calc" do
    assert "1" == Major.calc("1.2.3")
    assert "2" == Major.calc("2.0.0")
    assert "3" == Major.calc("3.1.0")
    assert "" == Major.calc("X")
  end
end
