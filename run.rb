class Run
  # usage: 
  #   r = Run.new(1000000)
  #   r.go
  #   r.show_stats
  #
  # example output:
  #
  #     NATURAL_ROYAL_FLUSH  4
  #    FOUR_WILDCARDS_W_ACE  1
  #         FOUR_WILDCARDS   17
  #        FIVE_KIND_ACES    22
  #        FIVE_KIND_3_5     59
  #     WILD_ROYAL_FLUSH     183
  #        FIVE_KIND_6_K     152
  #       STRAIGHT_FLUSH     760
  #            FOUR_KIND     12097
  #           FULL_HOUSE     4911
  #                FLUSH     5573
  #             STRAIGHT     61235
  #           THREE_KIND     116676
  #              NO_HAND     798310
  # 
  require 'video_poker'
  include VideoPoker
  include Cards

  attr_reader :stats

  def initialize(num_iter)
    @deck = Deck.new
    @num_iter = num_iter
    @he = HandEvaluator.new(@deck)
    @deck.wildcard = Card::TWO
    @stats = Hash.new {|h,k| h[k] = 0}
  end

  def draw_hand
    @deck.shuffle_up 10+rand(10)
    hand = @deck.deal_hands(1,5).first
    result = @he.evaluate(hand)
    hand.fold
    if result == Hands::NO_HAND
      # redraw all cards except wilds
    end
    @stats[result] += 1
    result
  end

  def go
    @num_iter.times {draw_hand}
  end

  def show_stats
    puts ""
    @stats.to_a.sort {|a,b| a[0] <=> b[0]}.each do |hand, count|
      puts "%20s   %d" % [VideoPoker::DESCRIPTIONS[hand], count]
    end
  end
end

r = Run.new((ARGV[0]||"10000").to_i)
r.go
r.show_stats
