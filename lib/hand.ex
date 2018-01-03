defmodule Poker.Hand do
  @card_names [
    {?2, 2}, {?3, 3}, {?4, 4}, {?5, 5}, {?6, 6}, {?7, 7}, {?8, 8}, {?9, 9},
    {?T, 10}, {?J, 'Jack'}, {?Q, 'Queen'}, {?K, 'King'}, {?A, 'Ace'}
  ]

  @special_combinations [:high_card, :straight, :flush, :straight_flush]

  @combinations %{
    high_card:       {"high card",       [1, 1, 1, 1, 1]},
    pair:            {"pair",            [2, 1, 1, 1]},
    two_pairs:       {"two pairs",       [2, 2, 1]},
    three_of_a_kind: {"three of a kind", [3, 1, 1]},
    straight:        {"straight",        [3, 1, 1, 1]},
    flush:           {"flush",           [3, 1, 1, 2]},
    full_house:      {"full house",      [3, 2]},
    four_of_a_kind:  {"four of a kind",  [4, 1]},
    straight_flush:  {"straight flush",  [5]}
  }

  for {{rank, name}, idx} <- Enum.with_index(@card_names) do
    defp card_value(unquote(rank)), do: unquote(idx)

    defp card_name(unquote(idx)), do: unquote(name)
  end

  for {symbol, {pair_name, ranks}} <- @combinations do
    if symbol != :high_card do
      def format({_, unquote(ranks)}), do: unquote(pair_name)
    else
      def format({[card | _], unquote(ranks)}),
        do: "#{ unquote(pair_name) }: #{card_name(card)}"
    end

    if symbol in @special_combinations do
      # TODO Awkward. There is a better way
      defp unquote(symbol)(ranks), do: {ranks, unquote(ranks)}
    end
  end

  @doc """
    Determines which one of two players has a stronger hand by comparing
    their scores first and then comparing their cards in the decreasing order

    ## Examples
        # higher score
        iex> Poker.Hand.stronger {[8, 7], [4, 1]}, {[10, 9, 8], [3, 1, 1]}
        true

        # same score - higher first rank
        iex> Poker.Hand.stronger {[8, 8], [4, 1]}, {[4, 10], [4, 1]}
        true

        # same score - same first ranks - higher second ranks
        iex> Poker.Hand.stronger {[8, 10], [4, 1]}, {[8, 6], [4, 1]}
        true
  """
  def stronger(acards, bcards) when acards == bcards, do: false
  def stronger({_, ascores}, {_, bscores}) when ascores > bscores, do: true
  def stronger({_, ascores}, {_, bscores}) when ascores < bscores, do: false
  def stronger({[a | _], _}, {[b | _], _}) when a > b, do: true
  def stronger({[a | _], _}, {[b | _], _}) when a < b, do: false

  def stronger({[_ | arest], ascores}, {[_ | brest], bscores}),
    do: stronger({arest, ascores}, {brest, bscores})

  @doc """
    Supplementary function that determines the winning combination or
    the higher card if both hands have the same ranks.

    Implies that higher hand is specified as the first argument
    TODO extract this function into different module probably Game or Poker

    ## Examples
        # tie
        iex> Poker.Hand.wins({[8, 7, 6], [2, 2, 1]}, {[8, 7, 6], [2, 2, 1]})
        :tie

        # higher score
        iex> Poker.Hand.wins({[8, 7], [4, 1]}, {[10, 9, 8], [3, 1, 1]})
        "four of a kind"

        # same score - higher first rank
        iex> Poker.Hand.wins({[8, 8], [4, 1]}, {[4, 10], [4, 1]})
        "high card: 10"

        # same score - same first ranks - higher second ranks
        iex> Poker.Hand.wins({[8, 10], [4, 1]}, {[8, 6], [4, 1]})
        "high card: Queen"
  """
  def wins(hand),
    do: format(hand)

  def wins(ahand, bhand) when ahand == bhand,
    do: :tie

  def wins({_, ascores} = hand, {_, bscores}) when ascores > bscores,
    do: format(hand)

  def wins({[afirst | _], _}, {[bfirst | _], _}) when afirst > bfirst,
    do: format(high_card([afirst]))

  def wins({[_ | arest], ascores}, {[_ | brest], bscores}),
    do: wins({arest, ascores}, {brest, bscores})

  @doc """
  Supplementary function to convert string with cards definition
  into list of pairs of  Ranks and Suits

  TODO Get rid of it. It's not a part of the Hand domain
  """
  def from_string(string) do
    string
    |> String.split()
  end

  @doc """
  Computes hand's score by computing histogram of cards and handling
  special conditions like flush and straight

    ## Examples
        # high card
        iex> Poker.Hand.score Poker.Hand.from_string("2C 3H 4S 8C AH")
        {[12, 6, 2, 1, 0], [1, 1, 1, 1, 1]}

        # pair
        iex> Poker.Hand.score Poker.Hand.from_string("2C 2H 4S 8C AH")
        {[0, 12, 6, 2], [2, 1, 1, 1]}

        # two pairs
        iex> Poker.Hand.score Poker.Hand.from_string("4H 4S 5C KH KS")
        {[11, 2, 3], [2, 2, 1]}

        # three of a kind
        iex> Poker.Hand.score Poker.Hand.from_string("4H 4C 4D 5C KH")
        {[2, 11, 3], [3, 1, 1]}

        #straight
        iex> Poker.Hand.score Poker.Hand.from_string("4H 5C 6D 7S 8D")
        {[6, 5, 4, 3, 2], [3, 1, 1, 1]}

        # flush
        iex> Poker.Hand.score Poker.Hand.from_string("4H 9H JH QH AH")
        {[12, 10, 9, 7, 2], [3, 1, 1, 2]}

        # full house
        iex> Poker.Hand.score Poker.Hand.from_string("4H 4C 4D KC KH")
        {[2, 11], [3, 2]}

        # four of a kind
        iex> Poker.Hand.score Poker.Hand.from_string("4H 4C 4D 4S 5D")
        {[2, 3], [4, 1]}

        # straight flush
        iex> Poker.Hand.score Poker.Hand.from_string("4H 5H 6H 7H 8H")
        {[6, 5, 4, 3, 2], [5]}
  """
  def score(cards) do
    frequencies =
      cards
      |> compute_scores
      |> Map.to_list()
      |> Enum.sort_by(fn {_, v} -> v end)
      |> Enum.reverse()
      |> Enum.unzip()

    {ranks, _} = frequencies
    straight = straight?(ranks)
    flush = flush?(cards)

    case frequencies do
      {ranks, _} when length(ranks) == 5 and straight and flush ->
        straight_flush(ranks)

      {ranks, _} when length(ranks) == 5 and flush ->
        flush(ranks)

      {ranks, _} when length(ranks) == 5 and straight ->
        straight(ranks)

      _ ->
        frequencies
    end
  end

  defp compute_scores(cards) do
    Enum.reduce(cards, %{}, fn <<rank, _>>, acc ->
      {_, acc} =
        Map.get_and_update(acc, card_value(rank), fn curr ->
          {curr, (curr || 0) + 1}
        end)

      acc
    end)
  end

  defp flush?([<<_, suit>> | _] = cards) do
    Enum.all?(cards, fn <<_, cardsuit>> -> cardsuit == suit end)
  end

  defp straight?([first | rest]), do: first - List.last(rest) == 4
end
