defmodule Mix.Tasks.Version.RcTest do
  use ExUnit.Case
  alias Mix.Tasks.Version.Rc

  test "calc" do
    assert "0" == Rc.calc("1.2.3")
    assert "0" == Rc.calc("2.0.0")
    assert "0" == Rc.calc("3.1.0-rc0")
    assert "1" == Rc.calc("3.1.0-rc1")
    assert "" == Rc.calc("")
  end
end
