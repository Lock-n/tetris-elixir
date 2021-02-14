defmodule Tetris.Brick do
  @x_center 40

  defstruct name: :i,
            location: {40, 0},
            rotation: 0,
            reflection: false

  alias Tetris.Points

  def new(attributtes \\ []) do
    __struct__(attributtes)
  end

  def new_random() do
    %__MODULE__{
      name: random_name(),
      location: {3, -3},
      rotation: random_rotation(),
      reflection: random_reflection()
    }
  end

  def random_name() do
    ~w(i l z o t)a
    |> Enum.random()
  end

  def random_rotation() do
    [0, 90, 180, 270]
    |> Enum.random()
  end

  def random_reflection() do
    [false, true]
    |> Enum.random()
  end

  def left(%__MODULE__{location: {x, y}} = brick) do
    %__MODULE__{brick | location: {x - 1, y}}
  end

  def right(%__MODULE__{location: {x, y}} = brick) do
    %__MODULE__{brick | location: {x + 1, y}}
  end

  def down(%__MODULE__{location: {x, y}} = brick) do
    %__MODULE__{brick | location: {x, y + 1}}
  end

  def spin_90(%__MODULE__{rotation: 270} = brick) do
    %__MODULE__{brick | rotation: 0}
  end

  def spin_90(%__MODULE__{rotation: rotation} = brick) do
    %__MODULE__{brick | rotation: rotation + 90}
  end

  def shape(%__MODULE__{name: :l}) do
    [
      {2, 1},
      {2, 2},
      {2, 3},
      {3, 3}
    ]
  end

  def shape(%__MODULE__{name: :i}) do
    [
      {2, 1},
      {2, 2},
      {2, 3},
      {2, 4}
    ]
  end

  def shape(%__MODULE__{name: :o}) do
    [
      {2, 2},
      {3, 2},
      {2, 3},
      {3, 3}
    ]
  end

  def shape(%__MODULE__{name: :z}) do
    [
      {2, 2},
      {2, 3},
      {3, 3},
      {3, 4}
    ]
  end

  def shape(%__MODULE__{name: :t}) do
    [
      {2, 1},
      {2, 2},
      {3, 2},
      {2, 3}
    ]
  end

  def prepare(brick) do
    brick
    |> shape
    |> Points.rotate(brick.rotation)
    |> Points.mirror(brick.reflection)
  end

  def to_string(brick) do
    brick
    |> prepare()
    |> Points.to_string()
  end

  def print(brick) do
    brick
    |> prepare()
    |> Points.print()

    brick
  end

  def x_center(), do: @x_center

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(brick, _opts) do
      concat([
        Tetris.Brick.to_string(brick),
        "\n",
        inspect(brick.location),
        " ",
        inspect(brick.reflection),
        " ",
        inspect(brick.rotation)
      ])
    end
  end
end
