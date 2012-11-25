class HandEvalTest
  require 'video_poker'
  require 'cards'

  def initialize
    deck = Cards::Deck.new
    deck.wildcard == Cards::Card::TWO
    @evaluator = VideoPoker::HandEvaluator.new(deck)
  end

  def run
    #
    # create hands in reverse hand value order and ensure that each is_ method
    # returns the correct boolean
    # NATURAL_ROYAL_FLUSH=1
    # FOUR_WILDCARDS_W_ACE=2
    # FOUR_WILDCARDS=3
    # FIVE_KIND_ACES=4
    # FIVE_KIND_3_5=5
    # WILD_ROYAL_FLUSH=6
    # FIVE_KIND_6_K=7
    # STRAIGHT_FLUSH=8
    # FOUR_KIND=9
    # FULL_HOUSE=10
    # FLUSH=11
    # STRAIGHT=12
    # THREE_KIND=13
    # NO_HAND=14
    #
    hand = Cards::Cards.make(*%w{JS AC 4D 8H 2D}) # NO_HAND
    raise "should be NO_HAND" if @evaluator.evaluate(hand) != VideoPoker::Hands::NO_HAND

    hand = Cards::Cards.make(*%w{JS JC JD 8H 4D}) # THREE_KIND
    raise "should be THREE_KIND" if @evaluator.evaluate(hand) != VideoPoker::Hands::THREE_KIND

    hand = Cards::Cards.make(*%w{JS JC 2D 8H 4D}) # THREE_KIND WITH 1 WILD
    raise "should be THREE_KIND" if @evaluator.evaluate(hand) != VideoPoker::Hands::THREE_KIND

    hand = Cards::Cards.make(*%w{JS 2C 2D 8H 4D}) # THREE_KIND WITH 2 WILD
    raise "should be THREE_KIND" if @evaluator.evaluate(hand) != VideoPoker::Hands::THREE_KIND
  end

end
