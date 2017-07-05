defmodule VersionTasks do

  def run(script) do
    script
    |> String.to_char_list
    |> :os.cmd
    |> List.to_string
    |> String.trim
    |> IO.puts
  end

end
