require"cosmo"

values = { rank="Ace", suit="Spades" } 
template = "$rank of $suit"
result = cosmo.fill(template, values) 
assert(result== "Ace of Spades")
  
mycards = { {rank="Ace", suit="Spades"}, {rank="Queen", suit="Diamonds"}, {rank="10", suit="Hearts"} } 
template = "$do_cards[[$rank of $suit, ]]"
result = cosmo.fill(template, {do_cards = mycards})  
assert(result=="Ace of Spades, Queen of Diamonds, 10 of Hearts, ")

result= cosmo.f(template){do_cards = mycards}
assert(result=="Ace of Spades, Queen of Diamonds, 10 of Hearts, ")

mycards = { {"Ace", "Spades"}, {"Queen", "Diamonds"}, {"10", "Hearts"} }
result = cosmo.f(template){
           do_cards = function()
              for i,v in ipairs(mycards) do
                 cosmo.yield{rank=v[1], suit=v[2]}
              end
           end
        }
assert(result=="Ace of Spades, Queen of Diamonds, 10 of Hearts, ")

table.insert(mycards, {"2", "Clubs"})
template = "You have: $do_cards[[$rank of $suit]],[[, $rank of $suit]],[[, and $rank of $suit]]"
result = cosmo.f(template){
           do_cards = function()
              for i,v in ipairs(mycards) do
                 if i == #mycards then -- for the last item use the third template (with "and")
                    template = 3
                 elseif i~=1 then -- use the second template for items 2...n-1
                    template = 2
                 end
                 cosmo.yield{rank=v[1], suit=v[2], _template=template}
              end
           end
        }
assert(result=="You have: Ace of Spades, Queen of Diamonds, 10 of Hearts, and 2 of Clubs")
   
players = {"John", "João"}
cards = {}
cards["John"] = mycards
cards["João"] = { {"Ace", "Diamonds"} }
template = "$do_players[=[$player has $do_cards[[$rank of $suit]],[[, $rank of $suit]],[[, and $rank of $suit]]\n]=]"
result = cosmo.f(template){
           do_players = function()
              for i,p in ipairs(players) do
                 cosmo.yield {
                    player = p,
                    do_cards = function()
                       for i,v in ipairs(cards[p]) do
                          local template
                          if i == #mycards then -- for the last item use the third template (with "and")
                             template = 3
                          elseif i~=1 then -- use the second template for items 2...n-1
                             template = 2
                          end
                          cosmo.yield{rank=v[1], suit=v[2], _template=template}
                       end
                    end
                 }         
             end
          end
        }
assert(result=="John has Ace of Spades, Queen of Diamonds, 10 of Hearts, and 2 of Clubs\nJoão has Ace of Diamonds\n")

template = "$do_players[=[$player$if_john[[$mark]] has $do_cards[[$rank of $suit, ]]\n]=]"
result = cosmo.f(template){
           do_players = function()
              for i,p in ipairs(players) do
                 cosmo.yield {
                    player = p,
                    do_cards = function()
                       for i,v in ipairs(cards[p]) do
                          cosmo.yield{rank=v[1], suit=v[2]}
                       end
                    end,
                    if_john = cosmo.c(p=="John"){mark="*"}
                 }         
             end
          end
        }

assert(result=="John* has Ace of Spades, Queen of Diamonds, 10 of Hearts, 2 of Clubs, \nJoão has Ace of Diamonds, \n")

