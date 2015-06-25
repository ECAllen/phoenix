defmodule Phoenix.Router.RouteTest do
  use ExUnit.Case, async: true

  import Phoenix.Router.Route

  test "builds a route based on verb, path, plug, plug options and helper" do
    route = build(:match, :get, "/foo/:bar", nil, Hello, :world, "hello_world", [:foo, :bar], %{foo: "bar"}, %{bar: "baz"})
    assert route.kind == :match
    assert route.verb == :get
    assert route.path == "/foo/:bar"
    assert route.host == nil

    assert route.plug == Hello
    assert route.opts == :world
    assert route.helper == "hello_world"
    assert route.pipe_through == [:foo, :bar]
    assert route.private == %{foo: "bar"}
    assert route.assigns == %{bar: "baz"}
  end

  test "builds expressions based on the route" do
    exprs = build(:match, :get, "/foo/:bar", nil, Hello, :world, "hello_world", [], %{}, %{}) |> exprs
    assert exprs.verb_match == "GET"
    assert exprs.path == ["foo", {:bar, [], nil}]
    assert exprs.binding == [{"bar", {:bar, [], nil}}]
    assert Macro.to_string(exprs.host) == "_"

    exprs = build(:match, :get, "/", "foo.", Hello, :world, "hello_world", [:foo, :bar], %{foo: "bar"}, %{bar: "baz"}) |> exprs
    assert Macro.to_string(exprs.host) == "\"foo.\" <> _"

    exprs = build(:match, :get, "/", "foo.com", Hello, :world, "hello_world", [], %{foo: "bar"}, %{bar: "baz"}) |> exprs
    assert Macro.to_string(exprs.host) == "\"foo.com\""
  end

  test "builds a catch-all verb_match for forwarded routes" do
    route = build(:forward, :*, "/foo/:bar", nil, Hello, :world, "hello_world", [:foo, :bar], %{foo: "bar"}, %{bar: "baz"})
    assert route.verb == :*
    assert route.kind == :forward
    assert exprs(route).verb_match == {:_verb, [], nil}
  end
end
