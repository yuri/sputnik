-- The data is taken from Wikipedia and is available under GFDL license.
DATA = {
[[The Sputnik program was a series of robotic spacecraft missions launched by the Soviet Union. The first of these, Sputnik 1, launched the first man-made object to orbit the Earth. That launch took place on October 4, 1957 as part of the International Geophysical Year and demonstrated the viability of using artificial satellites to explore the upper atmosphere.]],
[[O Sputnik foi o primeiro satélite artificial da Terra. Foi lançado pela União Soviética em 4 de outubro de 1957 no Soviet Union's rocket testing facility atualmente conhecido como Cosmódromo de Baikonur[1] no deserto próximo a Tyuratam na Cazaquistão[2]; o programa que o lançou chamou-se Sputnik I. O Sputnik era uma esfera de aproximadamente 58,5 cm e pesando 83,6 kg.]],
[[สปุตนิก (Sputnik) เป็นดาวเทียมดวงแรกของโลก ผลิตโดยประเทศรัสเซีย ลักษณะเป็นทรงกลมขนาดเท่าลูกบาสเกตบอล
ทำด้วยอะลูมิเนียมหนัก 84 กิโลกรัม ถูกส่งขึ้นวงโคจรด้วยหัวจรวดขีปนาวุธ อาร์-7 จากฐานปล่อยในทะเลทรายคีซิลคุม
ไบโคนูร์ คอสโมโดรม คาซัคสถาน เมื่อ 4 ตุลาคม พ.ศ. 2500 ]],
}
DATA_2 = {
[[The Sputnik program was a series of robotic spacecraft missions launched by the Soviet Union. The first of these, Sputnik 1, launched the first man-made object to orbit the Earth. That launch took place on October 4, 1957 as part of the International Geophysical Year and demonstrated the viability of using artificial satellites to explore the upper atmosphere.

The Russian name "Спутник" means literally "co-traveler", "traveling companion" or "satellite", and its R-7 launch vehicle was designed initially to carry nuclear warheads.]],
[[A função básica do satélite era transmitir um sinal de rádio, "beep", que podia ser sintonizado por qualquer radioamador nas frequências entre 20,005 e 40,002 MHz[3], emitidos continuamente durante 22 dias até que as baterias do transmissor esgotassem sua energia em 26 de outubro de 1957[4]. O satélite orbitou a Terra por seis meses antes de cair. Apesar das funcionalidades reduzidas do satélite, o programa Sputnik I ajudou a identificar as camadas da alta atmosfera terrestre através das mudanças de órbita do satélite. O satélite Sputnik era pressurizado internamente por nitrogênio, oferecendo também a primeira oportunidade de estudo sobre pequenos meteoritos, detectado através da despressurização interna ocasionada pelo impacto perfurante de um pequeno meteorito, evidenciado através de grandes variações internas de temperatura conforme a pressão diminuía. Tais variações de temperatura refletiram no sinal emitido pelo transmissor que foram monitorados pelo controle do satélite em terra.]],
[[スプートニク計画 (スプートニクけいかく) は1950年代後半に旧ソ連によって地球を回る軌道上に打ち上げられた、人類初の無人人工衛星の計画である。 スプートニク (Спутник, Sputnik) という言葉は「旅の道連れ」（転じて衛星）という意味のロシア語から来ている。

スプートニクはどれもR-7型ロケットによって軌道上に打ち上げられた。これは、元々は弾道ミサイル打ち上げ用に設計・開発されたものである。

これらの打ち上げ成功はソ連国民を勇気付ける一方、冷戦の相手であるアメリカ国民にショックを与え、宇宙開発競争の幕を切って落とすこととなった。]]
}


function make_timestamp()
   local t = os.date("*t")
   return string.format("%02d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
end

function generic_test(args)

   print("Testing versium implementation module "..args.module)

   -- Load the module
   local mod = require(args.module)
   assert(mod)

   -- Create a versium instance
   local v = mod.new(args.params)
   assert(v)

   -- Check that we have no nodes
   local nodes = v:get_node_ids()
   -- Verify there are no nodes in the blank repo
   assert(next(nodes) == nil)

   -- Create nodes and verify them after they've been saved

   local nodes = {}

   for i=1,3 do
      print("Round "..i)
      -- Assemble some random data
	  local name = "Спутник " .. i
	  local author = "程序员" .. i
      local author2 = "Програмист"..i
	  --local comment = "Совершенно секретно" .. i
      local comment2 = "Information you requested"
      -- Save the data
	  local version = v:save_version(name, DATA[i], author, comment)	  
      -- Check that it got saved properly
      assert(v:get_node(name) == DATA[i])
      -- Check the metadata
	  local metadata = v:get_node_info(name)
      assert(metadata.author == author)
      assert(metadata.comment == "") --comment)
      -- Save another version
	  v:save_version(name, DATA_2[i], author2, comment2)	  
      -- Check the new data
      assert(v:get_node(name) == DATA_2[i])
      -- Check the metadata
	  local metadata = v:get_node_info(name)
      assert(metadata.author == author2)
      assert(metadata.comment == comment2)
      -- Now check history
      local history = v:get_node_history(name)
      -- Check the previous version id
      assert(tostring(history[2].version) == tostring(version))
      -- Check old metadata
      assert(history[2].author == author)
      assert(history[2].comment == "") --comment)
      -- Check the old data
      assert(v:get_node(name, version) == DATA[i])
      -- Remember the latest version of the node for later
      nodes[name] = {data=DATA_2[i], author=author2, comment=comment2}
   end

   for id, info in pairs(nodes) do
      -- Check that the node is still there.
      assert(v:node_exists(id) == true)
      local data = v:get_node(id)
      assert(data == info.data)
      local metadata = v:get_node_info(id)
      assert(metadata.author == info.author)
      assert(metadata.comment == info.comment)
   end

   -- Test history
   local versions = {}
   local before = {}
   local after = {}
   for i=1,100 do
      local data = ""
      for i = 1,10 do
         data = data..tostring(math.random()*1000000)
      end
      versions[i] = data
      before[i] = make_timestamp()
      v:save_version("HistoryNode", data, "Tester", "Attempt #"..i)
      after[i] = make_timestamp()
   end

   -- Check that version 42
   local history = v:get_node_history("HistoryNode")
   local metadata = history[100-41]
   print(metadata.version)
   assert(v:get_node("HistoryNode", metadata.version) == versions[42])
   -- Check that the timing is right
   print(metadata.version)
   print(after[42])
   print(metadata.timestamp)
   print(before[42])
   --assert(metadata.timestamp >= before[42])
   --assert(metadata.timestamp <= after[42])

end

generic_test{
   module = "versium.filedir",
   params = {"/tmp/vtest"}
}

--[[generic_test{
   module = "versium.sqlite3",
   params = {"/tmp/vtest.db"}
}

generic_test{
   module = "versium.mysql",
   params = {"sputnik_db", "sputnik", "letmein", "localhost"},
}]]
