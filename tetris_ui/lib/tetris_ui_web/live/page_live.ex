defmodule TetrisUiWeb.PageLive do
  use TetrisUiWeb, :live_view

  @debug false
  @box_width 20
  @box_height 20

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval(250, :tick)

    {:ok, start_game(socket)}
  end

  def new_game(socket) do
    assign(socket, state: :playing, score: 0, bottom: %{}, game_over: false)
    |> new_block()
    |> show()
  end

  def start_game(socket) do
    assign(socket, state: :starting, score: 0, bottom: %{}, game_over: false)
    |> new_block()
    |> show()
  end

  def new_block(socket) do
    brick =
      Tetris.Brick.new_random()
      |> Map.put(:location, {3, -2})

    assign(socket, brick: brick)
  end

  def show(socket) do
    brick = socket.assigns.brick

    points =
      brick
      |> Tetris.Brick.prepare()
      |> Tetris.Points.move_to_location(brick.location)
      |> Tetris.Points.with_color(color(brick))

    assign(socket, tetromino: points)
  end

  @impl true
  def render(%{state: :playing} = assigns) do
    ~L"""
    <h1>Score: <%= @score %></h1>
    <div phx-keydown="keydown" tabindex="0" autofocus style="width: fit-content">
      <%= raw boxes(@tetromino ++ Map.values(@bottom)) %>
    </div>
    <%= debug(assigns) %>
    """
  end

  @impl true
  def render(%{state: :starting} = assigns) do
    ~L"""
    <h1>Welcome to Tetris!</h1>
    <button phx-click="start">Start</button>
    <%= debug(assigns) %>
    """
  end

  def render(%{state: :game_over} = assigns) do
    ~L"""
    <h1>Game Over</h1>
    <h2>Your score: <%= @score %></h2>
    <button phx-click="start">Play Again?</button>
    <%= debug(assigns) %>
    """
  end

  def svg(content) do
    """
    <svg
    version="1.0"
    style="background-color: #F8F8F8"
    id="Layer_1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    width="200" height="400"
    viewBox="0 0 200 400"
    xml:space="preserve">
    #{content}
    </svg>
    """
  end

  def boxes(points_with_colors) do
    points_with_colors
    |> Enum.map(fn {x, y, color} -> box({x, y}, color) end)
    |> Enum.join("\n")
    |> svg()
  end

  def box(point, color) do
    """
    #{square(point, shades(color).light)}
    #{triangle(point, shades(color).dark)}
    """
  end

  def square(point, shade) do
    {x, y} = to_pixels(point)

    """
    <rect
        x="#{x + 1}" y="#{y + 1}"
        style="fill:#{shade};"
        width="#{@box_width - 2}" height="#{@box_height - 1}"/>
    """
  end

  def triangle(point, shade) do
    {x, y} = to_pixels(point)
    {w, h} = {@box_width, @box_height}

    """
    <polyline
        style="fill:#{shade}"
        points="#{x + 1},#{y + 1} #{x + w},#{y + 1} #{x + w},#{y + h}" />
    """
  end

  defp to_pixels({x, y}), do: {(x - 1) * @box_width, (y - 1) * @box_height}

  defp shades(:red), do: %{light: "#DB7160", dark: "#AB574B"}
  defp shades(:blue), do: %{light: "#83C1C8", dark: "#66969C"}
  defp shades(:green), do: %{light: "#8BBF57", dark: "#769359"}
  defp shades(:orange), do: %{light: "#CB8E4E", dark: "#AC7842"}
  defp shades(:grey), do: %{light: "#A1A09E", dark: "#7F7F7E"}

  def color(%{name: :i}), do: :blue
  def color(%{name: :l}), do: :green
  def color(%{name: :z}), do: :grey
  def color(%{name: :o}), do: :orange
  def color(%{name: :t}), do: :red

  def move(direction, socket) do
    socket
    |> do_move(direction)
    |> show()
  end

  def drop(%{assigns: %{state: :playing}} = socket, fast) do
    %{assigns: %{brick: old_brick, bottom: bottom, score: old_score}} = socket

    %{brick: brick, game_over: game_over, bottom: bottom, score: score} =
      Tetris.drop(old_brick, bottom, color(old_brick))

    socket
    |> assign(
      brick: brick,
      state: if(game_over, do: :game_over, else: :playing),
      bottom: bottom,
      score: old_score + score + if(fast, do: 2, else: 0)
    )
    |> show()
  end

  def drop(%{assigns: %{state: _not_playing}} = socket, _fast), do: socket

  def do_move(%{assigns: %{brick: brick, bottom: bottom}} = socket, :left) do
    assign(socket, brick: brick |> Tetris.try_left(bottom))
  end

  def do_move(%{assigns: %{brick: brick, bottom: bottom}} = socket, :right) do
    assign(socket, brick: brick |> Tetris.try_right(bottom))
  end

  def do_move(%{assigns: %{brick: brick, bottom: bottom}} = socket, :turn) do
    assign(socket, brick: brick |> Tetris.try_spin_90(bottom))
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, move(:left, socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowRight"}, socket) do
    {:noreply, move(:right, socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowUp"}, socket) do
    {:noreply, move(:turn, socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowDown"}, socket) do
    {:noreply, drop(socket, true)}
  end

  @impl true
  def handle_event("keydown", %{"key" => _}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("start", _, socket), do: {:noreply, new_game(socket)}

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, drop(socket, false)}
  end

  def debug(assigns), do: debug(assigns, @debug, Mix.env())

  def debug(assigns, true, :dev) do
    ~L"""
    <pre><%= raw (@tetromino |> inspect) %></pre>
    """
  end

  def debug(assigns, false, _) do
    ~L""
  end
end
