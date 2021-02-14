defmodule BrickTest do
  use ExUnit.Case
  import Tetris.Brick
  alias Tetris.Points

  test "Creates a new brick" do
    assert new().name == :i
  end

  test "Creates a new random brick" do
    actual = new_random()

    assert actual.name in [:i, :l, :z, :o, :t]
    assert actual.rotation in [0, 90, 180, 270]
    assert actual.reflection in [true, false]
  end

  test "should manipulate brick" do
    actual =
      new()
      |> left
      |> right
      |> right
      |> down
      |> spin_90
      |> spin_90

    assert actual.location == {41, 1}
    assert actual.rotation == 180
  end

  test "should return points for i shape" do
    assert new(name: :i) |> shape() == [{2, 1}, {2, 2}, {2, 3}, {2, 4}]
  end

  test "should return points for o shape" do
    assert new(name: :o) |> shape() == [{2, 2}, {3, 2}, {2, 3}, {3, 3}]
  end

  test "should move_to_location a list of points" do
    assert new(name: :i)
           |> shape()
           |> Points.move_to_location({0, 2}) == [{2, 3}, {2, 4}, {2, 5}, {2, 6}]
  end

  test "should flip rotate flip and mirror" do
    [{1, 1}]
    |> Points.mirror()
    |> assert_point({4, 1})
    |> Points.flip()
    |> assert_point({4, 4})
    |> Points.rotate(90)
    |> assert_point({1, 4})
    |> Points.rotate(90)
    |> assert_point({1, 1})
  end

  test "should convert brick to string" do
    actual = new() |> Tetris.Brick.to_string()
    expected = "⬛⬜⬛⬛\n⬛⬜⬛⬛\n⬛⬜⬛⬛\n⬛⬜⬛⬛"

    assert actual == expected
  end

  test "should inspect bricks" do
    actual = new() |> inspect()

    expected = """
    ⬛⬜⬛⬛
    ⬛⬜⬛⬛
    ⬛⬜⬛⬛
    ⬛⬜⬛⬛
    {#{x_center()}, 0} false 0
    """

    assert "#{actual}\n" == expected
  end

  def assert_point([actual], expected) do
    assert actual == expected
    [actual]
  end
end
