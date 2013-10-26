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

  DESCRIPTIONS = {
    Hands::NATURAL_ROYAL_FLUSH  => "NATURAL_ROYAL_FLUSH",
    Hands::FOUR_WILDCARDS_W_ACE => "FOUR_WILDCARDS_W_ACE",
    Hands::FOUR_WILDCARDS       => "FOUR_WILDCARDS",
    Hands::FIVE_KIND_ACES       => "FIVE_KIND_ACES",
    Hands::FIVE_KIND_3_5        => "FIVE_KIND_3_5",
    Hands::WILD_ROYAL_FLUSH     => "WILD_ROYAL_FLUSH",
    Hands::FIVE_KIND_6_K        => "FIVE_KIND_6_K",
    Hands::STRAIGHT_FLUSH       => "STRAIGHT_FLUSH",
    Hands::FOUR_KIND            => "FOUR_KIND",
    Hands::FULL_HOUSE           => "FULL_HOUSE",
    Hands::FLUSH                => "FLUSH",
    Hands::STRAIGHT             => "STRAIGHT",
    Hands::THREE_KIND           => "THREE_KIND",
    Hands::NO_HAND              => "NO_HAND"
  }

  MAX_UNITS = 5 # player can bet up to this many of the chosen @bet

  class Game
    include Cards

    OUTPUT_INSET=4 # number of spaces to precede each line of game output
    NUM_CARDS_HAND=5

    attr_reader   :bank
    attr_reader   :name

    def initialize
      @deck = Deck.new
      @deck.wildcard = Card::TWO
      @evaluator = HandEvaluator.new(@deck)
      @max_units = MAX_UNITS

      welcome
      play
    end

    private

    def play
      #
      # start: accept_bet or quit
      # shuffle
      # deal poker hand face_up
      # display hand
      # evaluate hands and show possible payout
      # allow user to hold 0 to 5 cards
      # allow user to deal new cards, folding cards not held back to @deck
      # evaluate hands for highest
      # got back to :start if @bank > 0
      #
      init_game
      while true
        accept_bet
        shuffle
        deal_hand
        prompt_for_holds
        deal_after_holds
        player_outcome
        reset_game
      end
    end

    def welcome
      puts ""
      banner_print "video poker   video poker   video poker" % @name
      royal_flush = Cards.make(*("10S JS QS KS AS".split(' ')))
      royal_flush.up
      royal_flush.print
      banner_print "video poker   video poker   video poker" % @name
      puts ""
      @name = ask("What's your name") do |response|
        raise "You must enter a name" if response.length == 0
        response
      end
      banner_print "hey %s, welcome!" % @name
    end

    def init_game
      deal_show_hand_down
      @bank = prompt('Deposit Money to Start (in dollars)', ':') do |response| 
        iresp = response.to_i
        raise 'You must enter a whole dollar amount' unless iresp > 0 
        iresp
      end
      @unit = choice("Bet Unit?", "$%d.00", [1, 2, 5])
    end

    def deal_show_hand_down
      @hand = @deck.deal_hands(1, NUM_CARDS_HAND).first.down
      @hand.print
      @hand.fold
    end

    def deal_hand
      @hand = @deck.deal_hands(1, NUM_CARDS_HAND).first.up
      show_hand
    end

    def show_hand
      gputs ""
      gputs "Bet: $%d.00                Bank: $%d.00" % [@bet, @bank]
      @result = @evaluator.evaluate(@hand)
      gputs "You currently have %s" % DESCRIPTIONS[@result]
      @hand.print
      gputs [*1..NUM_CARDS_HAND].join("          ")
    end

    def prompt_for_holds
      range = 1..NUM_CARDS_HAND
      @holds = ask("Cards to Hold") do |response|
        digits = response.scan(/[0-9]+/).map(&:to_i)
        digits.each do |n|
          raise "Enter only numbers between 1 and #{NUM_CARDS_HAND} separated by space or comma" unless range.include?(n)
        end
        digits
      end
      @discards = ([*range] - @holds).map {|n| n - 1}
    end

    def accept_bet
      max_units = [@bank/@unit, @max_units].min
      @bet = ask("Bet (1-#{max_units})") do |amount|
        iresp = amount.to_i
        raise "enter and amount between 1 and #{max_units}" unless iresp >= 1 && iresp <= max_units
        iresp
      end
      @bank -= @bet
    end

    def deal_after_holds
      @hand.discard(@discards)
      @deck.deal_at(@hand, @discards, Card::FACE_UP)
      show_hand
    end

    def player_outcome
    end

    def reset_game
    end

    def game_over
      banner_print "game over"
      gputs "Returning $#{@bank}.00 to you.  Thanks for playing!" 
    end

    def choice(msg, formatter, options)
      len = options.length
      outbuf = msg + "\n"
      options.each_with_index do |o,i|
         outbuf << "  #{i+1}.  #{formatter}\n" % o
      end
      selection = prompt(outbuf, '>') do |resp|
        iresp = resp.to_i
        raise "you must choose 1 - #{len}" unless (1..len).include? iresp
        iresp
      end
      options[selection-1]
    end

    def ask(question, &block)
      prompt(question, '?', &block)
    end

    def prompt(question, sep)
      formatted_response=''
      begin
        response = prompt_user(question + sep + " ")
        if user_wants_to_quit?(response)
          game_over
          exit 0
        end
        formatted_response = yield response
      rescue StandardError => e
        gputs("\nSorry, #{e.message}.\n\n") 
        retry
      end
      formatted_response
    end

    def prompt_user(prompt)
      Readline.readline(prompt, true)
    end

    def banner_print(message)
      banner_message = "=== %s ===" % message.upcase
      banner = ("=" * banner_message.length)

      puts ""
      gputs banner
      gputs banner_message
      gputs banner
      puts ""
    end

    def gputs(output)
      puts "%s%s" % [(' ' * OUTPUT_INSET), output]
    end

    private

    def user_wants_to_quit?(line)
      if line =~ /^[Qq](uit)*$/
        resp = prompt_user("Really quit (y or n)? ")
        return true if resp =~ /^[Yy](es)*/
      end
      false
    end

    def shuffle
      @deck.shuffle_up(5+rand(5))
    end
  end

  class HandEvaluator
    include Cards

    ROYAL_FACES= [Card::TEN, Card::JACK, Card::QUEEN, Card::KING, Card::ACE]

    attr_accessor :hand

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

    def describe(hand)
      d = DESCRIPTIONS[e=evaluate(hand)]
      "#{hand} is a #{d} and pays #{PAYOUTS[e]} multiple"
    end

    def is_natural_royal_flush?
      all_same_suit?(@hand) && @hand.sort.map(&:face) == ROYAL_FACES
    end

    def is_four_wildcards_with_ace?
      has_four_wildcards? && has_ace?
    end

    def is_four_wildcards?
      has_four_wildcards?
    end

    def is_five_kind_3_5?
      is_five_kind?(*Card::FACES[1,3])
    end

    def is_five_kind_6_K?
      is_five_kind?(*Card::FACES[4,8])
    end

    def is_five_kind_aces?
      is_five_kind?(Card::ACE)
    end

    def is_wild_royal_flush?
      not_wild = cards_not_wild
      has_wildcard? && all_same_suit?(not_wild) && not_wild.all? {|card| ROYAL_FACES.include?(card.face)}
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
        return true if c2 == 2 && num_wild == 1
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
      #puts "wild #{wild}, not_wild #{not_wild}, consec #{consec}, freq #{freq.inspect}"
      return freq.first[1] >= consec
    end

    def is_straight_using_wilds?(not_wild, wild)
      wild_used = 0
      prev = nil
      not_wild.face_sort.each do |card|
        unless prev.nil?
          delta = face_delta(prev, card)
          return false if delta == 0 # same FACE in hand means straight impossible
          wild_used += (delta-1) # consecutive cards will not increment wild_used
          if (wild_used > wild.length)
            return false
          end
        end
        prev = card
      end
      true
    end

    def face_delta(card1, card2)
      (Card::FACES.index(card2.face) - Card::FACES.index(card1.face)).abs
    end

    def cards_not_wild
      Cards.new @deck, @hand.reject {|c| @deck.wild?(c)}
    end

    def cards_wild
      Cards.new @deck, @hand.select {|c| @deck.wild?(c)}
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
      #
      # face x 4 and 1 wild
      # face x 3 and 2 wild
      # face x 2 and 3 wild
      #
      num_wild = cards_wild.length
      of_these_faces.each do |face|
        cnt = face_count(face)
        return true if [4,3,2].include?(cnt) && (cnt + num_wild == 5)
      end
      false
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
      face_count(face) == count
    end

    def face_count(face)
      @hand.select {|c| c.face == face}.length
    end

    def has_ace?
      @hand.any? {|c| c.face == Card::ACE}
    end

    def has_wildcard?
      @hand.any? {|c| @deck.wild?(c)}
    end
  end
end
