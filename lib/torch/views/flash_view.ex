defmodule Torch.FlashView do
  @moduledoc """
  Contains functions for dealing with flash messages.
  """

  use Phoenix.View, root: "lib/torch/templates"
  use Phoenix.HTML

  import Phoenix.Controller, only: [get_flash: 2]

  @doc """
  Returns a formatted flash message of the given type.

  ## Parameters

  - `conn`: The current `Plug.Conn`.
  - `type`: The flash type, such as `:error`.

  ## Example

      iex> conn = %Plug.Conn{private: %{phoenix_flash: %{"error" => "Error Message"}}}
      ...> flash_message(conn, "error") |> safe_to_string()
      "<p class=\\"alert alert-danger alert-dismissible fade show\\">Error Message</p>"
  """
  @spec flash_message(Plug.Conn.t(), type :: atom | String.t()) :: Phoenix.HTML.safe()
  def flash_message(conn, type) do
    message = get_flash(conn, type)

    # remap(atom(for bootstrap))
    type =
      case type do
        :error -> :danger
        :info -> :info
        :success -> :success
        # default
        _ -> :danger
      end

    if message do
      content_tag :p, class: "alert alert-#{type} alert-dismissible fade show" do
        raw("#{message}")
      end
    end
  end
end
