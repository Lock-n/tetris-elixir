defmodule Tetris.Points do
  def move_to_location(points, {dx, dy}) do
    Enum.map(points, fn {x, y} -> {x + dx, y + dy} end)
  end

  def transpose(points) do
    Enum.map(points, &transpose_point/1)
  end

  def mirror(points, false), do: points
  def mirror(points, true), do: mirror(points)

  def mirror(points) do
    Enum.map(points, &mirror_point/1)
  end

  def flip(points) do
    Enum.map(points, &flip_point/1)
  end

  def rotate(points, 90) do
    points
    |> transpose()
    |> mirror()
  end

  def rotate(points, degrees) when rem(degrees, 360) == 0 do
    points
  end

  def rotate(points, degrees) do
    rotate(points, 90)
    |> rotate(degrees - 90)
  end

  defp transpose_point({x, y}), do: {y, x}
  defp mirror_point({x, y}), do: {5 - x, y}
  defp flip_point({x, y}), do: {x, 5 - y}

  def to_string(points) do
    map =
      points
      |> Enum.map(fn key -> {key, "⬜"} end)
      |> Map.new()

    for y <- 1..4, x <- 1..4 do
      Map.get(map, {x, y}, "⬛")
    end
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end

  def print(points) do
    points |> __MODULE__.to_string() |> IO.puts()
    points
  end

  def with_color(points, color) do
    Enum.map(points, fn point -> add_color(point, color) end)
  end

  defp add_color({_x, _y, _c} = point, _color), do: point
  defp add_color({x, y}, color), do: {x, y, color}
end
