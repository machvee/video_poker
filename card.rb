class Card

  include Comparable

  CLUBS='C'
  HEARTS='H'
  DIAMONDS='D'
  SPADES='S'

  CARD_TOP    = ".-------." # 0

  SUIT_PATTERNS = {
    HEARTS => [
      "|%2s_  _ |", # 1
      '| ( \/ )|',  # 2
      '|  \  / |',  # 3
      "|   \\/%2s|"  # 4
    ],
    DIAMONDS => [
      "|%2s /\\  |",
      '|  /  \ |',
      '|  \  / |',
      "|   \\/%2s|"
    ],
    CLUBS => [
      "|%2s _   |",
      "|  ( )  |",
      "| (_x_) |",
      "|   Y %2s|"
    ],
    SPADES => [
      "|%2s .   |",
      '|  / \  |',
      "| (_,_) |",
      "|   I %2s|"
    ]
  }

  CARD_BOTTOM = "`-------'" # 5

  NUM_PRINT_ROWS=6

  ACE   = 'A'
  TWO   = '2'
  THREE = '3'
  FOUR  = '4'
  FIVE  = '5'
  SIX   = '6'
  SEVEN = '7'
  EIGHT = '8'
  NINE  = '9'
  TEN   = '10'
  JACK  = 'J'
  QUEEN = 'Q'
  KING  = 'K'

  SUITS=[CLUBS, HEARTS, DIAMONDS, SPADES]
  FACES=[TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING, ACE]


  attr_reader :face
  attr_reader :suit

  FACE_DOWN=false
  FACE_UP=true
  attr_reader :facing  # FACE_UP, FACE_DOWN

  def initialize(face, suit, direction=FACE_DOWN)
    @face = face
    @suit = suit
    @facing = direction
  end

  def facing(direction)
    @facing = direction
  end

  def self.for(face_index, suit_index, direction=FACE_DOWN)
    Card.new(FACES[face_index-2], SUITS[suit_index], direction)
  end

  def to_s
    @face + @suit
  end

  def inspect
    to_s
  end

  def print_row(n)
    case n
      when 0
        CARD_TOP
      when 1,4
        @facing == FACE_UP ? SUIT_PATTERNS[@suit][n-1] % @face : "| x   x |"
      when 2,3
        @facing == FACE_UP ? SUIT_PATTERNS[@suit][n-1] : "|   x   |"
      when 5
        CARD_BOTTOM
    end
  end

  def print
    NUM_PRINT_ROWS.times do |i|
      puts print_row(i)
    end
    nil
  end

  def <=>(anOther)
    cmp = SUITS.index(@suit) <=> SUITS.index(anOther.suit)
    cmp.zero? ? FACES.index(@face) <=> FACES.index(anOther.face) : cmp
  end

  def self.all(direction=FACE_DOWN)
    a = []
    SUITS.each do |s|
      FACES.each do |f|
        a << Card.new(f, s, direction)
      end
    end
    a
  end
end
