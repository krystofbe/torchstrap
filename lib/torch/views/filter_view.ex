defmodule Torch.FilterView do
  @moduledoc """
  Provides input generators for Torch's filter sidebar.
  """

  use Phoenix.HTML

  import Torch.Gettext, only: [dgettext: 2]

  @type prefix :: atom | String.t()
  @type field :: atom | String.t()

  @doc """
  Generates a select box for a `belongs_to` association.

  ## Example

      iex> params = %{"post" => %{"category_id_equals" => 1}}
      ...> filter_assoc_select(:post, :category_id, [{"Articles", 1}], params) |> safe_to_string()
      "<select id=\\"post_category_id_equals\\" name=\\"post[category_id_equals]\\"><option value=\\"\\">Choose one</option><option value=\\"1\\" selected>Articles</option></select>"
  """
  @spec filter_assoc_select(prefix, field, list, map) :: Phoenix.HTML.safe()
  def filter_assoc_select(prefix, field, options, params) do
    select(
      prefix,
      :"#{field}_equals",
      options,
      value: params[to_string(prefix)]["#{field}_equals"],
      prompt: dgettext("default", "Choose one"),
      class: "form-control form-control-sm"
    )
  end

  @doc """
  Generates a "contains/equals" filter type select box for a given `string` or
  `text` field.

  ## Example

      iex> params = %{"post" => %{"title_contains" => "test"}}
      ...> filter_select(:post, :title, params) |> safe_to_string()
      "<select class=\\"form-control form-control-sm\\" id=\\"filters_\\" name=\\"filters[]\\"><option value=\\"post[title_contains]\\" selected>Contains</option><option value=\\"post[title_equals]\\">Equals</option></select>"
  """
  @spec filter_select(prefix, field, map) :: Phoenix.HTML.safe()
  def filter_select(prefix, field, params) do
    prefix_str = to_string(prefix)
    {selected, _value} = find_param(params[prefix_str], field)

    opts = [
      {dgettext("default", "Contains"), "#{prefix}[#{field}_contains]"},
      {dgettext("default", "Equals"), "#{prefix}[#{field}_equals]"}
    ]

    select(:filters, "", opts,
      class: "form-control form-control-sm",
      value: "#{prefix}[#{selected}]"
    )
  end

  @doc """
  Generates a number filter type select box for a given `number` field.

  ## Example

      iex> params = %{"post" => %{"rating_greater_than" => 0}}
      ...> number_filter_select(:post, :rating, params) |> safe_to_string()
      "<select class=\\"form-control form-control-sm\\" id=\\"filters_\\" name=\\"filters[]\\"><option value=\\"post[rating_equals]\\">Equals</option><option value=\\"post[rating_greater_than]\\" selected>Greater Than</option><option value=\\"post[rating_greater_than_or]\\">Greater Than Or Equal</option><option value=\\"post[rating_less_than]\\">Less Than</option></select>"
  """
  @spec number_filter_select(prefix, field, map) :: Phoenix.HTML.safe()
  def number_filter_select(prefix, field, params) do
    prefix_str = to_string(prefix)
    {selected, _value} = find_param(params[prefix_str], field)

    opts = [
      {dgettext("default", "Equals"), "#{prefix}[#{field}_equals]"},
      {dgettext("default", "Greater Than"), "#{prefix}[#{field}_greater_than]"},
      {dgettext("default", "Greater Than Or Equal"), "#{prefix}[#{field}_greater_than_or]"},
      {dgettext("default", "Less Than"), "#{prefix}[#{field}_less_than]"}
    ]

    select(:filters, "", opts,
      class: "form-control form-control-sm",
      value: "#{prefix}[#{selected}]"
    )
  end

  @doc """
  Generates a filter input for a number field.

  ## Example

      iex> params = %{"post" => %{"rating_equals" => 5}}
      ...> filter_number_input(:post, :rating, params) |> safe_to_string()
      "<input id=\\"post_rating_equals\\" name=\\"post[rating_equals]\\" type=\\"number\\" value=\\"5\\">"
  """
  @spec filter_number_input(prefix, field, map) :: Phoenix.HTML.safe()
  def filter_number_input(prefix, field, params) do
    prefix_str = to_string(prefix)
    {name, value} = find_param(params[prefix_str], field, :number)

    text_input(prefix, String.to_atom(name),
      value: value,
      type: "number",
      class: "form-control form-control-sm"
    )
  end

  @doc """
  Generates a filter input for a string field.

  ## Example

      iex> params = %{"post" => %{"title_contains" => "test"}}
      iex> filter_string_input(:post, :title, params) |> safe_to_string()
      "<input id=\\"post_title_contains\\" name=\\"post[title_contains]\\" type=\\"text\\" value=\\"test\\">"
  """
  @spec filter_string_input(prefix, field, map) :: Phoenix.HTML.safe()
  def filter_string_input(prefix, field, params) do
    prefix_str = to_string(prefix)
    {name, value} = find_param(params[prefix_str], field)
    text_input(prefix, String.to_atom(name), value: value, class: "form-control form-control-sm")
  end

  @doc """
  DEPRECATED: Generates a filter input for a text field.
  Use the `filter_string_input/3` function instead.
  """
  @deprecated "Use filter_string_input/3 instead"
  def filter_text_input(prefix, field, params) do
    filter_string_input(prefix, field, params)
  end

  @doc """
  Generates a filter datepicker input.

  ## Example

      iex> params = %{"post" => %{"inserted_at_between" => %{"start" => "01/01/2018", "end" => "01/31/2018"}}}
      ...> filter_date_input(:post, :inserted_at, params) |> safe_to_string()
      "<input class=\\"datepicker start\\" name=\\"post[inserted_at_between][start]\\" placeholder=\\"Select Start Date\\" type=\\"text\\" value=\\"01/01/2018\\"><input class=\\"datepicker end\\" name=\\"post[inserted_at_between][end]\\" placeholder=\\"Select End Date\\" type=\\"text\\" value=\\"01/31/2018\\">"
  """
  @spec filter_date_input(prefix, field, map) :: Phoenix.HTML.safe()
  def filter_date_input(prefix, field, params) do
    prefix = to_string(prefix)
    field = to_string(field)

    {:safe, start} =
      torch_date_input(
        "#{prefix}[#{field}_between][start]",
        get_in(params, [prefix, "#{field}_between", "start"]),
        dgettext("default", "start")
      )

    {:safe, ending} =
      torch_date_input(
        "#{prefix}[#{field}_between][end]",
        get_in(params, [prefix, "#{field}_between", "end"]),
        dgettext("default", "end")
      )

    raw(start ++ ending)
  end

  @doc """
  Generates a filter select box for a boolean field.

  ## Example

      iex> params = %{"post" => %{"draft_equals" => "false"}}
      iex> filter_boolean_input(:post, :draft, params) |> safe_to_string()
      "<select id=\\"post_draft_equals\\" name=\\"post[draft_equals]\\"><option value=\\"\\">Choose one</option><option value=\\"true\\">True</option><option value=\\"false\\" selected>False</option></select>"
  """
  @spec filter_boolean_input(prefix, field, map) :: Phoenix.HTML.safe()
  def filter_boolean_input(prefix, field, params) do
    value =
      case get_in(params, [to_string(prefix), "#{field}_equals"]) do
        nil -> nil
        string when is_binary(string) -> string == "true"
      end

    select(
      prefix,
      :"#{field}_equals",
      [{"True", true}, {"False", false}],
      value: value,
      prompt: dgettext("default", "Choose one"),
      class: "form-control form-control-sm"
    )
  end

  defp torch_date_input(name, value, "start") do
    tag(
      :input,
      type: "text",
      class: "datepicker start",
      name: name,
      value: value,
      placeholder: dgettext("default", "Select Start Date")
    )
  end

  defp torch_date_input(name, value, "end") do
    tag(
      :input,
      type: "text",
      class: "datepicker end",
      name: name,
      value: value,
      placeholder: dgettext("default", "Select End Date")
    )
  end

  defp torch_date_input(name, value, class) do
    tag(:input, type: "text", class: "datepicker #{class}", name: name, value: value)
  end

  defp find_param(params, pattern, type \\ :string) do
    pattern = to_string(pattern)

    result =
      Enum.find(params || %{}, fn {key, _val} ->
        String.starts_with?(key, pattern)
      end)

    cond do
      result == nil && type == :string -> {"#{pattern}_contains", nil}
      result == nil && type == :number -> {"#{pattern}_equals", nil}
      result != nil -> result
    end
  end
end
