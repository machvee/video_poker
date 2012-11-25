module VideoPoker
  require 'cards'
  require 'readline'

  module Hands
    NATURAL_ROYAL_FLUSH=1
    FOUR_WILDCARDS_W_ACE=2
    FOUR_WILDCARDS=3
    FIVE_KIND_ACES=4
    FIVE_KIND_3_5=5
    WILD_ROYAL_FLUSH=6
    FIVE_KIND_6_K=7
    STRAIGHT_FLUSH=8
    FOUR_KIND=9
    FULL_HOUSE=10
    FLUSH=11
    STRAIGHT=12
    THREE_KIND=13
    NO_HAND=14
  end

  PAYOUTS = {
    Hands::NATURAL_ROYAL_FLUSH  => 800,
    Hands::FOUR_WILDCARDS_W_ACE => 400,
    Hands::FOUR_WILDCARDS       => 200,
    Hands::FIVE_KIND_ACES       =>  80,
    Hands::FIVE_KIND_3_5        =>  40,
    Hands::WILD_ROYAL_FLUSH     =>  25,
    Hands::FIVE_KIND_6_K        =>  20,
    Hands::STRAIGHT_FLUSH       =>  10,
    Hands::FOUR_KIND            =>   4,
    Hands::FULL_HOUSE           =>   4,
    Hands::FLUSH                =>   3,
    Hands::STRAIGHT             =>   1,
    Hands::THREE_KIND           =>   1,
    Hands::NO_HAND              =>   0
  }

  class Game
    include Cards

    attr_reader   :bank
    attr_reader   :name

    def initialize(player_name, buyin)
      @bank = buyin
      @name = player_name
      @deck = Deck.new
      @deck.wildcard = Card::TWO
      shuffle
      @evaluator = HandEvaluator.new(@deck)
    end

    def play
      #
      # accept tokens
      # shuffle
      # deal poker hand face_up
      # display hand
      # evaluate hands and show possible payout
      # allow user to hold 0 to 5 cards
      # allow user to deal new cards, folding cards not held back to @deck
      # evaluate hands for highest
      #
    end

    def shuffle
      @deck.shuffle_up(5+rand(5))
    end
  end

  class HandEvaluator
    include Cards
    # 
    # determine the highest poker hand and return the Module Hands value, or NO_HAND
    #
    def initialize(deck)
      @deck = deck
    end

    def evaluate(hand)
      @hand = hand
      return Hands::NATURAL_ROYAL_FLUSH if is_natural_royal_flush?
      return Hands::FOUR_WILDCARDS_W_ACE if is_four_wildcards_with_ace?
      return Hands::FOUR_WILDCARDS if is_four_wildcards?
      return Hands::FIVE_KIND_ACES if is_five_kind_aces?
      return Hands::FIVE_KIND_3_5 if is_five_kind_3_5?
      return Hands::WILD_ROYAL_FLUSH if is_wild_royal_flush?
      return Hands::FIVE_KIND_6_K if is_five_kind_6_K?
      return Hands::STRAIGHT_FLUSH if is_straight_flush?
      return Hands::FOUR_KIND if is_four_kind?
      return Hands::FULL_HOUSE if is_full_house?
      return Hands::FLUSH if is_flush?
      return Hands::STRAIGHT if is_straight?
      return Hands::THREE_KIND if is_three_kind?
      return Hands::NO_HAND
    end

    def is_natural_royal_flush?
      all_same_suit?(@hand) && @hand.sort.map(&:face) == %w{10 J Q K A}
    end

    def is_four_wildcards_with_ace?
      has_four_wildcards? && has_ace?
    end

    def is_four_wildcards?
      has_four_wildcards?
    end

    def is_five_kind_aces?
      is_four_of?(Card::ACE) && has_wildcard?
    end

    def is_five_kind_3_5?
      is_five_kind?(*Card::FACES[1,3])
    end

    def is_wild_royal_flush?
      not_wild = cards_not_wild
      has_wildcard? && all_same_suit?(not_wild) && not_wild.all? {|card| royal_faces.include?(card.face)}
    end

    def is_five_kind_6_K?
      is_five_kind?(*Card::FACES[4,8])
    end

    def is_straight_flush?
      not_wild = cards_not_wild
      all_same_suit?(not_wild) && is_straight_using_wilds?(not_wild, cards_wild)
    end

    def is_four_kind?
      is_n_kind?(4)
    end

    def is_full_house?
      not_wild = cards_not_wild
      wild = cards_wild
      num_wild = wild.length
      freq = face_freq(not_wild)
      c1 = freq[0][1]
      c2 = freq[1][1]
      if c1 == 3
        # C1 C1 C1 C2 C2
        # C1 C1 C1 C2  W
        return true if c2 == 2
        return true if num_wild == 1
        return false
      end
      if c1 == 2
        # C1 C1  W C2 C2 or C2 C2  W C1 C1
        # C1  W  W C2 C2
        return true if c2 == 2 && num_wild == 1
        return true if c2 == 1 && num_wild == 2
      end
      false
    end

    def is_flush?
      all_same_suit?(cards_not_wild)
    end

    def is_straight?
      is_straight_using_wilds?(cards_not_wild, cards_wild)
    end

    def is_three_kind?
      is_n_kind?(3)
    end

    def is_n_kind?(consec)
      not_wild = cards_not_wild
      wild = cards_wild
      consec = consec - wild.length
      # find the highest consec number of same-faced non-wild cards,
      # and try to add in wilds to make n-of a kind
      freq = face_freq(not_wild)
      return freq.first[1] >= consec
    end

    def is_straight_using_wilds?(not_wild, wild)
      wild_used = 0
      prev = nil
      not_wild.face_sort.each do |card|
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
      @hand.reject {|c| @deck.wild?(c)} YOU ARE HERE... needs Cards object returned
    end

    def cards_wild
      @hand.select {|c| @deck.wild?(c)} YOU ARE HERE... needs Cards object returned
    end

    def face_freq(hand)
      # sort by count of same faces and then by highest face value
      #
      # return  e.g.  [["K", 2], ["3", 2'], ['7', 1]]
      #
      h = Hash.new {|h,k| h[k] = 0}
      hand.each {|card| h[card.face] += 1}
      h.to_a.sort {|a,b| (cmp = b[1] <=> a[1]).zero? ? Card::FACES.index(b[0]) <=> Card::FACES.index(a[0]) : cmp}
    end

    def is_five_kind?(*of_these_faces)
      has_wildcard? && of_these_faces.any? {|face| is_four_of?(face)}
    end

    def is_four_of?(face)
      has_count_of?(4, face)
    end

    def all_same_suit?(cards)
      one_suit = cards[0].suit
      cards[0..-1].all? {|c| c.suit == one_suit}
    end
    
    def has_four_wildcards?
      is_four_of?(@deck.wildcard)
    end

    def has_count_of?(count, face)
      @hand.select {|c| c.face == face}.length == count
    end

    def has_ace?
      @hand.any? {|c| c.face == Card::ACE}
    end

    def has_wildcard?
      @hand.any? {|c| @deck.wild?(c)}
    end

    def royal_faces
      [Card::TEN, Card::JACK, Card::QUEEN, Card::KING, Card::ACE]
    end
  end
end
