class Deck < Cards

  def initialize(num_decks=1, direction=Card::FACE_DOWN)
    cards = []
    num_decks.times {cards += Card.all(direction)}
    super(nil, cards)
  end

  def deal_hands(num_hands, how_many_cards, direction=Card::FACE_DOWN)
    #
    # create Hands from this deck, dealing one card out at a time to each Hand
    #
    hands=[]
    num_hands.times {hands << deal(1, direction)}
    (how_many_cards-1).times do
      hands.each do |hand|
        transfer(hand, 1, direction)
      end
    end
    hands
  end

end
