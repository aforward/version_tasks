defmodule VersionTasks.FnExpr do
  @moduledoc """

  THIS IS A DUPLICATE OF https://hex.pm/packages/fn_expr so that
  project can leverage this version management (avoiding) a circular
  dependency.

  If you want this functionality, then please install it instead

        @deps [
          fn_expr: "~> 0.1.0"
        ]
  """
  defmacro __using__(_) do
    quote do
      defmacro invoke(piped_in_argument, expr) do
        fun = is_tuple(expr) && elem(expr, 0)

        case fun do
          :fn ->
            quote do
              unquote(expr).(unquote(piped_in_argument))
            end

          _ ->
            quote do
              (&unquote(expr)).(unquote(piped_in_argument))
            end
        end
      end
    end
  end

  def default(piped_in_argument, default_value) do
    case piped_in_argument do
      nil -> default_value
      _ -> piped_in_argument
    end
  end

  defmacro unquote(:&&)(piped_in_argument, expr) do
    quote do
      (&unquote(expr)).(unquote(piped_in_argument))
    end
  end
end
