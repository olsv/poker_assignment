defmodule PokerTest do
  use ExUnit.Case, async: true
  #doctest Poker

  defp subject(players) do
    Poker.compare(players)
  end

  setup do
    cards = %{
      high_card:       "2C 3H 4S 8C JH",
      pair:            "3H 3D 5S 9C KD",
      two_pairs:       "KH KD 3S 3C QD",
      three_of_a_kind: "KH KD KS QC 8D",
      straight:        "5H 6D 7S 8C 9D",
      flush:           "5H 6H 7H TH JH",
      full_house:      "QH QS QC 4H 4D",
      four_of_a_kind:  "QH QS QH QD 3D",
      straight_flush:  "9H TH JH QH KH"
    }

    %{cards: cards}
  end

  test "compare straight flush", %{cards: cards} do
    assert subject(White: cards[:straight_flush], Black: "TS JS QS KS AS") ==
      "Black wins - high card: Ace"
  end

  test "compare four of a kind", %{cards: cards} do
    assert subject(White: cards[:four_of_a_kind], Black: "KH KS KC KD 2D") ==
      "Black wins - high card: King"

    assert subject(White: cards[:four_of_a_kind], Black: "JH JS JC JD AD") ==
      "White wins - high card: Queen"
  end

  test "compare full house", %{cards: cards} do
    assert subject(White: cards[:full_house], Black: "KH KS KC AH AS") ==
      "Black wins - high card: King"

    assert subject(White: cards[:full_house], Black: "JH JS JC AH AS") ==
      "White wins - high card: Queen"
  end

  test "compare flush", %{cards: cards} do
    assert subject(White: cards[:flush], Black: "5S 6S 7S KS TS") ==
      "Black wins - high card: King"

    assert subject(White: cards[:flush], Black: "5S 6S 7S TS JS") ==
      "Tie"
  end

  test "compare straight", %{cards: cards} do
    assert subject(White: cards[:straight], Black: "6H 7D 8S 9C TD") ==
      "Black wins - high card: 10"

    assert subject(White: cards[:straight], Black: "5S 6C 7H 8H 9C") ==
      "Tie"
  end

  test "compare three of a kind", %{cards: cards} do
    assert subject(White: cards[:three_of_a_kind], Black: "AH AD AS QH 8H") ==
      "Black wins - high card: Ace"

    assert subject(White: cards[:three_of_a_kind], Black: "JH JD JS KH QH") ==
      "White wins - high card: King"
  end

  test "compare two pairs", %{cards: cards} do
    assert subject(White: cards[:two_pairs], Black: "AH AD 3C 3D 8H") ==
      "Black wins - high card: Ace"

    assert subject(White: cards[:two_pairs], Black: "KH KD 4S 4C QD") ==
      "Black wins - high card: 4"

    assert subject(White: cards[:two_pairs], Black: "KS KC 3H 3D AC") ==
      "Black wins - high card: Ace"

    assert subject(White: cards[:two_pairs], Black: "KS KC 3H 3D QC") ==
      "Tie"
  end

  test "compare pair", %{cards: cards} do
    assert subject(White: cards[:pair], Black: "4C 4H 6C TD AH") ==
      "Black wins - high card: 4"

    assert subject(White: cards[:pair], Black: "3C 3S 6C AH TD") ==
      "Black wins - high card: Ace"

    assert subject(White: cards[:pair], Black: "3C 3S 5C 9D KH") ==
      "Tie"
  end

  test "compare high card", %{cards: cards} do
    assert subject(White: cards[:high_card], Black: "2H 3D 5S 9C KD") ==
      "Black wins - high card: King"

    assert subject(White: cards[:high_card], Black: "2H 3D 4C 8H JD") ==
      "Tie"
  end

  test "compare one player supplied", %{cards: cards} do
    assert subject(White: cards[:pair]) == "White wins - pair"
  end

  test "compare when no players supplied" do
    assert subject([]) == "Tie"
  end
end
