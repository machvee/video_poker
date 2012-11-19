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

    def evaluate
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
      # evaluate hands for highest
    end

    def is_natural_royal_flush?
      all_same_suit?(@hand) && @hand.sort.map(&:face) == %w{10 J Q K A}
    end

    def is_four_deuces_w_ace
      has_four_deuces? && has_ace?
    end

    def is_four_deuces?
      has_four_deuces?
    end

    def is_five_kind_aces?
      is_four_of?(Card::ACE) && has_deuce?
    end

    def is_five_kind_3_5?
      is_five_kind?(Card::FACES[1,3])
    end

    def is_wild_royal_flush?
      not_wild = cards_not_wild
      has_deuce? && all_same_suit?(not_wild) && not_wild.all? {|card| royal_faces.include?(card.face)}
    end

    def is_five_kind_6_K?
      is_five_kind?(Card::FACES[4,8])
    end

    def is_straight_flush?
      not_wild = cards_not_wild
      all_same_suit?(not_wild) && is_straight_using_wilds?(not_wild, cards_wild)
    end

    def is_four_kind?
      not_wild = cards_not_wild.sort.reverse
      wild = cards_wild
      consec = 4 - wild.length
      # find the highest consec number of same-faced non-wild cards,
      # and try to add in wilds to make 4 of a kind

    end

    def is_full_house?
      wild = cards_wild
      not_wild = cards_not_wild.sort
    end

    def is_flush?
      all_same_suit?(cards_not_wild)
    end

    def is_straight?
      is_straight_using_wilds?(cards_not_wild, cards_wild)
    end

    def is_three_kind?
    end

    def is_straight_using_wilds?(not_wild, wild)
      wild_used = 0
      prev = nil
      not_wild.sort.each do |card|
        unless prev.nil?
          unless consecutive_faces?(prev, card)
            wild_used += 1
            if (wild_used > wild.length)
              return false
            end
          end
        end
        prev = card
      end
      true
    end

    def consecutive_faces?(card1, card2)
      Card::FACES.index(card2) - Card::FACES.index(card1) == 1
    end

    def cards_not_wild
      @hand.reject {|c| c.wild?}
    end

    def cards_wild
      @hand.select {|c| c.wild?}
    end

    def is_five_kind?(*of_these_faces)
      has_deuce? && of_these_faces.any? {|face| is_four_of?(face)}
    end

    def is_four_of?(face)
      has_count_of?(4, face)
    end

    def all_same_suit?(cards)
      one_suit = cards[0].suit
      cards[0..-1].any? {|c| c.suit != one_suit}
    end
    
    def has_four_deuces?
      is_four_of?(@deck.wildcard)
    end

    def has_count_of?(count, face)
      @hand.select {|c| c.face == face}.length == count
    end

    def has_ace?
      @hand.any? {|c| c.face == Card::ACE}
    end

    def has_deuce?
      @hand.any? {|c| c.face == @deck.wildcard}
    end

    def royal_faces
      [Card::TEN, Card::JACK, Card::QUEEN, Card::KING, Card::ACE]
    end
  end

end
