defmodule Tetris do
  alias Tetris.{Bottom, Brick, Points}

  def prepare(brick) do
    brick
    |> Brick.prepare()
    |> Points.move_to_location(brick.location)
  end

  def try_move(brick, bottom, f) do
    new_brick = f.(brick)

    if Bottom.collides?(bottom, prepare(new_brick)) do
      brick
    else
      new_brick
    end
  end

  def drop(brick, bottom, color) do
    new_brick = Brick.down(brick)

    maybe_do_drop(
      Bottom.collides?(bottom, prepare(new_brick)),
      bottom,
      brick,
      new_brick,
      color
    )
  end

  def maybe_do_drop(true = _collided, bottom, old_brick, _new_block, color) do
    points =
      old_brick
      |> prepare
      |> Points.with_color(color)

    {count, new_bottom} = Bottom.merge(bottom, points) |> Bottom.full_collapse()

    new_brick = Brick.new_random()

    %{
      brick: new_brick,
      bottom: new_bottom,
      score: score(count),
      game_over: Bottom.collides?(new_bottom, prepare(new_brick))
    }
  end

  def maybe_do_drop(false = _collided, bottom, _old_block, new_block, _color) do
    %{
      brick: new_block,
      bottom: bottom,
      score: 1,
      game_over: false
    }
  end

  def score(0), do: 0

  def score(count) do
    100 * round(:math.pow(2, count))
  end

  def try_left(brick, bottom), do: try_move(brick, bottom, &Brick.left/1)
  def try_right(brick, bottom), do: try_move(brick, bottom, &Brick.right/1)
  def try_spin_90(brick, bottom), do: try_move(brick, bottom, &Brick.spin_90/1)
end
