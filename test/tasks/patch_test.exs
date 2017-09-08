defmodule Mix.Tasks.Version.PatchTest do
  use ExUnit.Case
  alias Mix.Tasks.Version.Patch

  test "calc" do
    assert "3" == Patch.calc("1.2.3")
    assert "0" == Patch.calc("2.0.0")
    assert "0" == Patch.calc("3.1.0")
    assert "4" == Patch.calc("5.1.4")
    assert "" == Patch.calc("")
  end
end
