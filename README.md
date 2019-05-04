[![Hex.pm](https://img.shields.io/hexpm/v/torchstrap.svg)](https://hex.pm/packages/torchstrap)
[![Build Status](https://travis-ci.org/krystofbe/torchstrap.svg?branch=master)](https://travis-ci.org/krystofbe/torchstrap)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/krystofbe/torchstrap.svg)](https://beta.hexfaktor.org/github/krystofbe/torchstrap)

<p align="center">
  <img width="489" alt="phoenix_torchstrap_logo" src="https://user-images.githubusercontent.com/7085617/37124853-ef17cec8-221e-11e8-97b9-bb6d13188500.png">
</p>

# Torchstrap

Torchstrap is a rapid admin generator for Phoenix apps inspired by daniel berkompas' Torch . It creates custom templates and relies
on the Bootstrap Framework under the hood.

![image](https://user-images.githubusercontent.com/7085617/36333572-70e3907e-132c-11e8-9ad2-bd5e98aadc7c.png)

## Installation

To install Torchstrap, perform the following steps:

1. Add `torchstrap` to your list of dependencies in `mix.exs`. Then, run `mix deps.get`:

```elixir
def deps do
  [
    {:torchstrap, "~> 2.0.0-rc.1"}
  ]
end
```

2. Add a `Plug.Static` plug to your `endpoint.ex`:

```elixir
plug(
  Plug.Static,
  at: "/torchstrap",
  from: {:torchstrap, "priv/static"},
  gzip: true,
  cache_control_for_etags: "public, max-age=86400"
)
```

3. Configure Torchstrap by adding the following to your `config.exs`.

```
config :torchstrap,
  otp_app: :my_app_name,
  template_format: "eex" || "slim"
```

4. Run `mix torchstrap.install`

NOTE: If you choose to use `slim` templates, you will need to [install Phoenix Slim](https://github.com/slime-lang/phoenix_slime).

Now you're ready to start generating your admin! :tada:

## Usage

Torchstrap uses Phoenix generator code under the hood. Torchstrap injects it's own custom templates
into your `priv/static` directory, then runs the `mix phx.gen.html` task with the options
you passed in. Finally, it uninstalls the custom templates so they don't interfere with
running the plain Phoenix generators.

In light of that fact, the `torchstrap.gen.html` task takes all the same arguments as the `phx.gen.html`,
but does some extra configuration on either end. Checkout `mix help phx.gen.html` for more details
about the supported options and format.

For example, if we wanted to generate a blog with a `Post` model we could run the following command:

```bash
$ mix torchstrap.gen.html Blog Post posts title:string body:text published_at:datetime published:boolean views:integer
```

The output would look like:

```bash
Add the resource to your browser scope in lib/my_app_web/router.ex:

    resources "/posts", PostController

Ensure the following is added to your endpoint.ex:

    plug(
      Plug.Static,
      at: "/torchstrap",
      from: {:torchstrap, "priv/static"},
      gzip: true,
      cache_control_for_etags: "public, max-age=86400",
      headers: [{"access-control-allow-origin", "*"}]
    )

  :fire: Torchstrap generated html for Posts! :fire:
```

Torchstrap also installed an admin layout into your `my_app_web/templates/layout/torchstrap.html.eex`.
You will want to update it to include your new navigation link:

```
<nav class="torchstrap-nav">
  <a href="/posts">Posts</a>
</nav>
```

### Association filters

Torchstrap does not support association filters at this time. [Filtrex](https://github.com/rcdilorenzo/filtrex) does not yet support them.

You can checkout these two issues to see the latest updates:

https://github.com/rcdilorenzo/filtrex/issues/55

https://github.com/rcdilorenzo/filtrex/issues/38

However, that does not mean you can't roll your own.

**Example**

We have a `Accounts.User` model that `has_many :credentials, Accounts.Credential` and we want to support filtering users
by `credentials.email`.

1. Update the `Accounts` domain.

```elixir
# accounts.ex
...
defp do_paginate_users(filter, params) do
  credential_params = Map.get(params, "credentials")
  params = Map.drop(params, ["credentials"])

  User
  |> Filtrex.query(filter)
  |> credential_filters(credential_params)
  |> order_by(^sort(params))
  |> paginate(Repo, params, @pagination)
end

defp credential_filters(query, nil), do: query

defp credential_filters(query, params) do
  search_string = "%#{params["email"]}%"

  from(u in query,
    join: c in assoc(u, :credentials),
    where: like(c.email, ^search_string),
    group_by: u.id
  )
end
...
```

2. Update form filters.

```eex
# users/index.html.eex
<div class="field">
  <label>Credential email</label>
  <%= text_input(:credentials, :email, value: maybe(@conn.params, ["credentials", "email"])) %>
</div>
```

Note: You'll need to install & import `Maybe` into your views `{:maybe, "~> 1.0.0"}` for
the above `eex` to work.

## Styling

Torchstrap generates a CSS file you need to use: `base.css`. In the future there will be a custom theme in `base.css`. Please note that Torchstrap doesn't come with Bootstrap. You need to include Bootstrap's CSS yourself. Just change the stylesheet link in the `torchstrap.html.eex` layout.
