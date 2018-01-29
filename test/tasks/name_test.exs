defmodule Mix.Tasks.Version.NameTest do
  use ExUnit.Case
  alias Mix.Tasks.Version.Name

  test "name" do
    assert :patch == Name.calc("1.2.3")
    assert :patch == Name.calc("1.2.30")
    assert :patch == Name.calc("2.0.1")

    assert :minor == Name.calc("0.1.0")
    assert :minor == Name.calc("1.4.0")

    assert :major == Name.calc("1.0.0")
    assert :major == Name.calc("2.0.0")
  end
end
