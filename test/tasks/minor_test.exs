defmodule Mix.Tasks.Version.MinorTest do
  use ExUnit.Case
  alias Mix.Tasks.Version.Minor

  test "calc" do
    assert "2" == Minor.calc("1.2.3")
    assert "0" == Minor.calc("2.0.0")
    assert "1" == Minor.calc("3.1.0")
    assert "" == Minor.calc("X")
  end
end
