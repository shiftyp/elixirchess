defmodule Board do
  alias Constants, as: C

  @moduledoc """
  Board contains methods for parsing fen postions and serializing board tuples
  """

  @doc """
  The parsePosition function takes a position from a fen string and converts it
  into a tuple where each item is a tuple which represents the piece and color
  occupying the square. It is the inverse of serializeBoard. For example:

  iex> Board.parsePosition("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R")
  {
    {:r, :b}, {:n, :b}, {:b, :b}, {:q, :b}, {:k, :b}, {:b, :b}, {:n, :b}, {:r, :b},
    {:p, :b}, {:p, :b}, {:e, :e}, {:p, :b}, {:p, :b}, {:p, :b}, {:p, :b}, {:p, :b},
    {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e},
    {:e, :e}, {:e, :e}, {:p, :b}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e},
    {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:p, :w}, {:e, :e}, {:e, :e}, {:e, :e},
    {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:n, :w}, {:e, :e}, {:e, :e},
    {:p, :w}, {:p, :w}, {:p, :w}, {:p, :w}, {:e, :e}, {:p, :w}, {:p, :w}, {:p, :w},
    {:r, :w}, {:n, :w}, {:b, :w}, {:q, :w}, {:k, :w}, {:b, :w}, {:e, :e}, {:r, :w}
  }
  """
  @spec parsePosition(binary) :: tuple

  def parsePosition(position) do
    position
      |> String.codepoints()
      |> createSquares()
      |> List.to_tuple()
  end

  @spec createSquares(list) :: list

  defp createSquares([piece | rest]) do
    square = pieceToSquare(piece)
    cond do
      rest == [] and square == nil -> []
      rest == [] -> [square]
      square == {:e, :e} ->
        newPiece = piece
          |> String.to_integer()
          |> - 1
          |> Integer.to_string()
        [square | createSquares([newPiece | rest])]
      square != nil -> [ square | createSquares(rest)]
      true -> createSquares(rest)
    end
  end

  @spec pieceToSquare(binary) :: tuple

  defp pieceToSquare(piece) when piece == "/" or piece == "0" do
    nil
  end

  defp pieceToSquare(piece) when piece < "9" do
    {:e, :e}
  end

  defp pieceToSquare(piece) do
    case piece do
      "p" -> {:p, :b}
      "P" -> {:p, :w}
      "n" -> {:n, :b}
      "N" -> {:n, :w}
      "b" -> {:b, :b}
      "B" -> {:b, :w}
      "r" -> {:r, :b}
      "R" -> {:r, :w}
      "k" -> {:k, :b}
      "K" -> {:k, :w}
      "q" -> {:q, :b}
      "Q" -> {:q, :w}
    end
  end

  @doc """
  The serializeBoard function takes a board (the tuple returned from create board)
  and returns a position suitible for putting in a fen string. It is the inverse
  of createBoard. For example:

  iex> Board.serializeBoard({
  ...>  {:r, :b}, {:n, :b}, {:b, :b}, {:q, :b}, {:k, :b}, {:b, :b}, {:n, :b}, {:r, :b},
  ...>  {:p, :b}, {:p, :b}, {:e, :e}, {:p, :b}, {:p, :b}, {:p, :b}, {:p, :b}, {:p, :b},
  ...>  {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e},
  ...>  {:e, :e}, {:e, :e}, {:p, :b}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e},
  ...>  {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:p, :w}, {:e, :e}, {:e, :e}, {:e, :e},
  ...>  {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:e, :e}, {:n, :w}, {:e, :e}, {:e, :e},
  ...>  {:p, :w}, {:p, :w}, {:p, :w}, {:p, :w}, {:e, :e}, {:p, :w}, {:p, :w}, {:p, :w},
  ...>  {:r, :w}, {:n, :w}, {:b, :w}, {:q, :w}, {:k, :w}, {:b, :w}, {:e, :e}, {:r, :w}
  ...> })
  "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R"
  """

  @spec serializeBoard(tuple) :: binary

  def serializeBoard(board) do
    board
      |> Tuple.to_list()
      |> serializeSquares(0, "", [])
      |> List.to_string
  end

  @spec serializeSquares(list, integer, binary, list) :: list

  defp serializeSquares([square | rest], index, prev, acc) when rem(index, 8) == 0 and index > 0 do
    new = serializeSquare square, ""
    serializeSquares(rest, index + 1, new, [acc | [prev, "/"]])
  end

  defp serializeSquares([square | rest], index, prev, acc) do
    new = serializeSquare square, prev
    case rest do
      [] -> [acc | [prev, new]]
      _ ->
        if prev < "9" and prev > "0" and new < "9" do
          serializeSquares(rest, index + 1, new, acc)
        else
          serializeSquares(rest, index + 1, new, [acc | prev])
        end
    end
  end

  @spec serializeSquare(tuple, binary) :: binary

  defp serializeSquare({:e, _}, prev) do
     cond do
      prev == "" or prev > "8" -> "1"
      true ->
        prev
          |> String.to_integer()
          |> + 1
          |> Integer.to_string()
     end
  end

  defp serializeSquare({piece, color}, _) do
     C.symbols[color][piece]
  end
end
