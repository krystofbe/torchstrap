defmodule Torch.Config do
  @moduledoc """
  Application config for torch.
  """

  def otp_app do
    Application.get_env(:torchstrap, :otp_app)
  end

  def template_format do
    Application.get_env(:torchstrap, :template_format)
  end
end
