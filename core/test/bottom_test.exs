defmodule BottomTest do
  use ExUnit.Case
  import Tetris.Bottom

  test "various collisions" do
    bottom = %{{1, 1} => {1, 1, :blue}}

    assert collides?(bottom, {1, 1})
    refute collides?(bottom, {1, 2})
    assert collides?(bottom, {1, 1, :blue})
    assert collides?(bottom, {1, 1, :red})
    refute collides?(bottom, {1, 2, :red})
    assert collides?(bottom, [{1, 2, :red}, {1, 1, :red}])
    refute collides?(bottom, [{1, 2, :red}, {1, 3, :red}])
  end

  test "various collisions with top and lower margin" do
    bottom = %{}

    assert collides?(bottom, {0, 1})
    refute collides?(bottom, {1, 2})
    assert collides?(bottom, {11, 1, :blue})
    assert collides?(bottom, {1, 21, :red})
    refute collides?(bottom, {1, 20, :red})
    assert collides?(bottom, [{11, 2, :red}, {10, 1, :red}])
    refute collides?(bottom, [{1, 2, :red}, {1, 3, :red}])
  end

  test "simple merge test" do
    bottom = %{{1, 1} => {1, 1, :blue}}

    actual = merge(bottom, [{1, 2, :red}, {1, 3, :red}])

    expected = %{
      {1, 1} => {1, 1, :blue},
      {1, 2} => {1, 2, :red},
      {1, 3} => {1, 3, :red}
    }

    assert actual == expected
  end

  test "compute complete ys" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    assert complete_ys(bottom) == [20]
  end

  test "collapse a single row" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    actual = bottom |> collapse_row(20) |> Map.keys()

    assert actual == [{19, 20}]
  end

  test "full collapse with single row" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    {actual_count, actual_bottom} = bottom |> full_collapse()

    assert actual_count == 1
    assert Map.keys(actual_bottom) == [{19, 20}]
  end

  def new_bottom(complete_row, xtras) do
    (xtras ++
       (1..10
        |> Enum.map(fn x ->
          {{x, complete_row}, {x, complete_row, :red}}
        end)))
    |> Map.new()
  end
end
