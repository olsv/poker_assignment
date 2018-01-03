defmodule Poker do
  alias Poker.Hand
  @moduledoc """
  Documentation for Poker.
  """

  @doc """
  Determines a winner basing on the two players with the highest score
  and returns either Tie if their hands are equal or string containing
  the name of the winner and the reason of the win.

    ## Examples
        iex> Poker.compare Black: "2H 3D 5S 9C KD", White: "2C 3H 4S 8C AH"
        "White wins - high card: Ace"

        iex> Poker.compare Black: "2H 4S 4C 3D 4H", White: "2S 8S AS QS 3S"
        "White wins - flush"

        iex> Poker.compare Black: "2H 3D 5S 9C KD", White: "2C 3H 4S 8C KH"
        "Black wins - high card: 9"

        iex> Poker.compare Black: "2H 3D 5S 9C KD", White: "2D 3H 5C 9S KH"
        "Tie"
  """
  def compare(players) when is_list(players) do
    players
    |> compute_scores
    |> arrange_by_score
    |> determine_winner
  end

  def compare(_) do
    {:error, "List of players must be supplied"}
  end

  defp determine_winner([]),
    do: "Tie"

  defp determine_winner([{player, hand}]),
    do: "#{ player } wins - #{ Hand.wins(hand) }"

  defp determine_winner([{player, acards}, {_, bcards} | _]) do
    case Hand.wins(acards, bcards) do
      :tie -> "Tie"
      reason -> "#{ player } wins - #{ reason }"
    end
  end

  defp compute_scores(players) do
    Enum.map players, fn  {player, cards} ->
      {player, Hand.score(Hand.from_string(cards))}
    end
  end

  defp arrange_by_score(players) do
    Enum.sort_by(players, fn {_, hand} -> hand end, &Hand.stronger/2)
  end
end
