class Cards

  attr_reader :cards
  attr_reader :card_source

  def initialize(card_source, cards=[])
    @card_source = card_source
    @cards = cards
  end

  def shuffle
    @cards.shuffle!
  end

  def shuffle_up(num_times=1)
    num_times.times {shuffle; split}
    @cards
  end

  def facing(direction=Card::FACE_DOWN)
    @cards.each {|c| c.facing(direction)}
  end

  def split
    #
    # pick a random spot in the middle third of the deck
    # and split the deck there
    #
    third = num_cards/3
    split_at = third + rand(third)
    @cards = @cards.slice(split_at..-1) + @cards.slice(0,split_at)
  end

  def transfer(destination, num_cards, direction=Card::FACE_DOWN)
    destination.add(remove(num_cards, direction))
  end

  def deal(how_many=1, direction=Card::FACE_DOWN)
    #
    # create a new Cards object using how_many from this set
    #
    Cards.new(self, remove(how_many, direction))
  end

  def fold(direction=Card::FACE_DOWN)
    #
    # return @cards to the @card_source
    #
    transfer(@card_source, num_cards, direction)
  end

  def add(cards)
    @cards += cards
  end

  def remove(how_many, direction)
    raise "too few cards remaining" if how_many > num_cards
    @cards.slice!(0, how_many).each {|c| c.facing(direction)}
  end

  def order
    @cards.sort!
  end

  def num_cards
    @cards.length
  end

  def to_s
    @cards.map &:to_s
  end

  def inspect
    @cards.inspect
  end

  def [](index)
    @cards[index]
  end

  def print
    sep = "  "
    row = ""
    Card::NUM_PRINT_ROWS.times do |i|
      puts @cards.map {|card| card.print_row(i)}.join(sep)
    end
    nil
  end

end
