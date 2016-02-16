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
    # We convert the string to a char list, then we create a list from it.
    # Ultimately we want a touple since the size of a chess board is fixed, and
    # we'll want to access it by index.
    position
      |> String.codepoints()
      |> createSquares()
      |> List.to_tuple()
  end

  @spec createSquares(list) :: list

  defp createSquares([piece | rest]) do
    # Get the square, nil for non-square characters
    square = pieceToSquare(piece)
    cond do
      # We've reached the end after an empty square
      rest == [] and square == nil -> []
      # We've reached the end with a non-empty square
      rest == [] -> [square]
      # If the square is empty, add it and process the next square by
      # decrementing the empty counter
      square == {:e, :e} ->
        newPiece = piece
          |> String.to_integer()
          |> - 1
          |> Integer.to_string()
        [square | createSquares([newPiece | rest])]
      # If we have a non-nil square (i.e. a piece)
      square != nil -> [ square | createSquares(rest)]
      # Otherwise we've hit a slash or the end of an empty sequence, so skip.
      true -> createSquares(rest)
    end
  end

  @spec pieceToSquare(binary) :: tuple

  # Non-square characters are nil.
  defp pieceToSquare(piece) when piece == "/" or piece == "0" do
    nil
  end

  # Empty squares are indicated by a counter (still a string).
  defp pieceToSquare(piece) when piece < "9" do
    {:e, :e}
  end

  # Pieces are indicated by their letter, with uppercase indicating white and
  # lowercase indicating black.
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
  of parsePosition. For example:

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
    # We convert the board from a tuple since we'll be looking at the first elem.
    # We start off at index 0 with an empty string and an empty accumulator. It's
    # possible that it would be more performant to change the serialization logic
    # To prepend items to the list, then reverse it at the end. This isn't how it's
    # currently implemented.
    board
      |> Tuple.to_list()
      |> serializeSquares(0, "", [])
      |> List.to_string
  end

  # The arguments are the remaning squares as a list, an index in the sequence,
  # a string representing the last proccessed symbol, and a list representing the
  # accumulated symbols going into the final string.In the end we return that list.
  # The current symbol isn't appended to the list until the next function call,
  # except in the case where we are at the end of the list of squares. This is to
  # account for empty squares being represented by a single symbol, so it's a
  # reduce operation as opposed to a straight map.
  @spec serializeSquares(list, integer, binary, list) :: list

  # This is the end of a row case, where we want to add a "/" to the list. Note
  # That this will only match in between the rows, and not at the beginning or
  # end of the sequence.
  defp serializeSquares([square | rest], index, prev, acc) when rem(index, 8) == 0 and index > 0 do
    # We pass an empty string as prev just like at the start of the process.
    new = serializeSquare square, ""
    # We don't treat the slash as a symbol, so we don't pass it to the next call.
    serializeSquares(rest, index + 1, new, [acc | [prev, "/"]])
  end

  defp serializeSquares([square | rest], index, prev, acc) do
    new = serializeSquare square, prev
    cond do
      # If we're at the end of the list, finish it up.
      rest == [] -> [acc | [prev, new]]
      # If the previous and current square are both empty.
      prev < "9" and prev > "0" and new < "9" ->
        serializeSquares(rest, index + 1, new, acc)
      # Otherwise we append the previous to the accumulator and move on to the
      # next call.
      true ->
        serializeSquares(rest, index + 1, new, [acc | prev])
    end
  end

  @spec serializeSquare(tuple, binary) :: binary

  defp serializeSquare({:e, :e}, prev) do
    # For empty squares, we return a "1" if the prev square was non-empty,
    # Otherwise it was empty and we increment that number.
    if prev == "" or prev > "8" do
      "1"
    else
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
