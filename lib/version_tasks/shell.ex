defmodule VersionTasks.Shell do
  def info(raw_msg, args \\ %{}) do
    case parse(raw_msg, args) do
      {:quiet, msg} ->
        msg

      {:ok, msg} ->
        if has_mix?() do
          Mix.shell().info(msg)
        else
          IO.puts(msg)
        end
    end
  end

  def inspect(data, %{quiet: true_or_false}), do: true_or_false |> _inspect(data)
  def inspect(data, args), do: Enum.member?(args, "--quiet") |> _inspect(data)

  defp _inspect(false, data), do: IO.inspect(data)
  defp _inspect(true, data), do: data

  def error(raw_msg, args \\ %{}) do
    case parse(raw_msg, args) do
      {:quiet, msg} ->
        msg

      {:ok, msg} ->
        if has_mix?() do
          Mix.shell().error(msg)
        else
          IO.puts(msg)
        end
    end
  end

  def raise(raw_msg, args \\ %{}) do
    case parse(raw_msg, args) do
      {:quiet, msg} ->
        msg

      {:ok, msg} ->
        if has_mix?() do
          Mix.raise(msg)
        else
          Kernel.raise(msg)
        end
    end
  end

  def newline, do: info("")

  defp has_mix?, do: function_exported?(Mix, :shell, 1)

  defp parse(msg, args), do: _parse(msg |> clean, args)
  defp _parse(msg, %{quiet: true}), do: {:quiet, msg}

  defp _parse(msg, args) when is_list(args) do
    if Enum.member?(args, "--quiet") do
      {:quiet, msg}
    else
      {:ok, msg}
    end
  end

  defp _parse(msg, _), do: {:ok, msg}
  defp clean(msg) when is_binary(msg), do: msg
  defp clean(msg), do: "#{msg}"
end
