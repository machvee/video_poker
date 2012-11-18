module VideoPoker
  require 'cards'
  require 'readline'

  include Cards

  module Hands
    NATURAL_ROYAL_FLUSH=800
    FOUR_DEUCES_W_ACE=400
    FOUR_DEUCES=200
    FIVE_KIND_ACES=80
    FIVE_KIND_3_5=40
    WILD_ROYAL_FLUSH=25
    FIVE_KIND_6_K=20
    STRAIGHT_FLUSH=10
    FOUR_KIND=4
    FULL_HOUSE=4
    FLUSH=3
    STRAIGHT=1
    THREE_KIND=1
  end

  def Game
    attr_reader   :bank
    attr_reader   :name

    def initialize(player_name, buyin)
      @bank = buying
      @name = player_name
      @deck = Deck.new
      @deck.wildcard = Card::TWO
      @deck.shuffle_up(5+rand(5))
    end

    def play
      #
      # accept tokens
      # shuffle_up
      # deal poker hand face_up
      # display hand
      # evaluate hands and show possible payout
      # allow user to hold 0 to 5 cards
      # allow user to deal new cards, folding cards not held back to @deck
      # evaluate hands
    end
  end

end
