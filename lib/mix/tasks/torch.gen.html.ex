defmodule Mix.Tasks.Torch.Gen.Html do
  @moduledoc """
  Light wrapper module around `mix phx.gen.html` which generates slightly
  modified HTML.

  Takes all the same params as the `phx.gen.html` task.

  ## Example

      mix torch.gen.html Accounts User users --no-schema
  """

  alias Mix.Phoenix
  alias Mix.Phoenix.{Context, Schema}
  alias Mix.Project
  alias Mix.Tasks.Phx.Gen
  alias Mix.Tasks.Phx.Gen.Html
  alias Mix.Torch

  @commands ~w[phx.gen.html phx.gen.context]

  def run(args) do
    %{format: format} = Torch.parse_config!("torch.gen.html", args)

    # Inject the torch templates for the generator into the priv/
    # directory so they will be picked up by the Phoenix generator
    Enum.each(@commands, &Torch.inject_templates(&1, format))

    # Run the Phoenix generator
    phx_gen_html(args)

    # Remove the injected templates from priv/ so they will not
    # affect future Phoenix generator commands
    Enum.each(@commands, &Torch.remove_templates/1)

    Mix.shell().info("""
    Ensure the following is added to your endpoint.ex:

        plug(
          Plug.Static,
          at: "/torch",
          from: {:torchstrap, "priv/static"},
          gzip: true,
          cache_control_for_etags: "public, max-age=86400",
          headers: [{"access-control-allow-origin", "*"}]
        )
    """)

    Mix.shell().info("""
    Also don't forget to add a link to layouts/torch.html.

      <nav class="my-2 my-md-0 mr-md-3" />
        <a class="p-2 text-dark" href="#Mypage">MyPage</a>
      </nav>
    """)
  end

  def phx_gen_html(args) do
    if Project.umbrella?() do
      Mix.raise("mix phx.gen.html can only be run inside an application directory")
    end

    {context, schema} = Gen.Context.build(args)
    Gen.Context.prompt_for_code_injection(context)

    binding = [context: context, schema: schema, inputs: inputs(schema)]
    paths = Phoenix.generator_paths()

    prompt_for_conflicts(context)

    context
    |> Html.copy_new_files(paths, binding)
    |> Html.print_shell_instructions()
  end

  defp inputs(%Schema{} = schema) do
    Enum.map(schema.attrs, fn
      {_, {:references, _}} ->
        {nil, nil, nil}

      {key, :integer} ->
        {label(key),
         ~s(<%= number_input f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, :float} ->
        {label(key),
         ~s(<%= number_input f, #{inspect(key)}, class: "form-control form-control-sm", step: "any" %>),
         error(key), "form-group"}

      {key, :decimal} ->
        {label(key),
         ~s(<%= number_input f, #{inspect(key)}, class: "form-control form-control-sm", step: "any" %>),
         error(key), "form-group"}

      {key, :boolean} ->
        {~s(<%= checkbox f, #{inspect(key)}, class: "form-check-input" %>),
         label(key, "form-check-label"), error(key), "form-check"}

      {key, :text} ->
        {label(key),
         ~s(<%= textarea f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, :date} ->
        {label(key),
         ~s(<%= date_select f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, :time} ->
        {label(key),
         ~s(<%= time_select f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, :utc_datetime} ->
        {label(key),
         ~s(<%= datetime_select f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, :naive_datetime} ->
        {label(key),
         ~s(<%= datetime_select f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, {:array, :integer}} ->
        {label(key),
         ~s(<%= multiple_select f, #{inspect(key)}, ["1": 1, "2": 2], class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, {:array, _}} ->
        {label(key),
         ~s(<%= multiple_select f, #{inspect(key)}, ["Option 1": "option1", "Option 2": "option2"], class: "form-control form-control-sm" %>),
         error(key), "form-group"}

      {key, _} ->
        {label(key),
         ~s(<%= text_input f, #{inspect(key)}, class: "form-control form-control-sm" %>),
         error(key), "form-group"}
    end)
  end

  defp label(key, class \\ "") do
    ~s(<%= label f, #{inspect(key)}, class: #{inspect(class)} %>)
  end

  defp error(field) do
    ~s(<%= error_tag f, #{inspect(field)} %>)
  end

  defp prompt_for_conflicts(context) do
    context
    |> Html.files_to_be_generated()
    |> Kernel.++(context_files(context))
    |> Phoenix.prompt_for_conflicts()
  end

  defp context_files(%Context{generate?: true} = context) do
    Gen.Context.files_to_be_generated(context)
  end

  defp context_files(%Context{generate?: false}) do
    []
  end
end
