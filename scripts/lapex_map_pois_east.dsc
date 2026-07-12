lapex_map_poi_relay:
  type: task
  debug: false
  definitions: world
  script:
  # High relay plateau, operations block, antenna mast, and landing pad.
  - ~run lapex_map_disc def:<[world]>|225|86|-225|36|2|31|stone_bricks
  - ~run lapex_map_disc def:<[world]>|225|88|-225|34|1|29|smooth_stone
  - ~run lapex_map_road def:<[world]>|225|88|-268|225|88|-247|7|gray_concrete
  - ~run lapex_map_hollow def:<[world]>|201|88|-242|229|98|-218|light_gray_concrete|polished_andesite|gray_concrete
  - ~run lapex_map_box def:<[world]>|211|89|-218|217|93|-216|air
  - ~run lapex_map_box def:<[world]>|201|91|-234|202|95|-228|air
  - ~run lapex_map_hollow def:<[world]>|234|88|-225|252|96|-207|gray_concrete|polished_andesite|light_gray_concrete
  - ~run lapex_map_box def:<[world]>|240|89|-207|246|93|-205|air
  - ~run lapex_map_tower def:<[world]>|241|89|-239|29|red_concrete
  - ~run lapex_map_disc def:<[world]>|241|108|-239|8|1|8|iron_block
  - ~run lapex_map_disc def:<[world]>|241|110|-239|5|1|5|white_concrete
  - ~run lapex_map_box def:<[world]>|238|116|-242|244|117|-236|red_concrete
  - ~run lapex_map_box def:<[world]>|240|115|-249|242|118|-230|iron_block
  - ~run lapex_map_disc def:<[world]>|207|89|-202|11|1|11|black_concrete
  - ~run lapex_map_disc def:<[world]>|207|90|-202|8|1|8|light_gray_concrete
  - ~run lapex_map_box def:<[world]>|205|90|-209|209|90|-195|yellow_concrete
  - ~run lapex_map_box def:<[world]>|214|89|-247|218|92|-243|orange_concrete
  - ~run lapex_map_box def:<[world]>|219|89|-247|223|91|-243|gray_concrete
  - ~run lapex_map_box def:<[world]>|226|89|-247|230|92|-243|orange_concrete
  - ~run lapex_map_box def:<[world]>|197|89|-248|200|91|-245|iron_block
  - ~run lapex_map_box def:<[world]>|252|89|-239|255|91|-235|iron_block
  - ~run lapex_map_box def:<[world]>|221|91|-229|229|91|-221|smooth_stone

lapex_map_poi_wetlands:
  type: task
  debug: false
  definitions: world
  script:
  # A flooded stilt village connected by raised boardwalks.
  - ~run lapex_map_pool def:<[world]>|211|61|-113|17|12
  - ~run lapex_map_pool def:<[world]>|241|60|-96|14|10
  - ~run lapex_map_pool def:<[world]>|229|60|-132|10|8
  - ~run lapex_map_disc def:<[world]>|189|65|-115|7|8|28|mossy_cobblestone
  - ~run lapex_map_disc def:<[world]>|262|65|-116|7|8|26|tuff
  - ~run lapex_map_disc def:<[world]>|235|67|-154|22|7|6|stone
  - ~run lapex_map_disc def:<[world]>|199|61|-96|10|2|8|mud
  - ~run lapex_map_disc def:<[world]>|249|61|-119|9|2|7|mud
  - ~run lapex_map_box def:<[world]>|195|64|-108|255|65|-104|mangrove_planks
  - ~run lapex_map_box def:<[world]>|222|64|-139|226|65|-82|mangrove_planks
  - ~run lapex_map_box def:<[world]>|205|57|-107|207|63|-105|mangrove_log
  - ~run lapex_map_box def:<[world]>|243|56|-107|245|63|-105|mangrove_log
  - ~run lapex_map_box def:<[world]>|223|56|-126|225|63|-124|mangrove_log
  - ~run lapex_map_hut def:<[world]>|193|65|-123|14|7|11|mangrove_planks|dark_oak_planks
  - ~run lapex_map_hut def:<[world]>|233|65|-122|14|7|11|mangrove_planks|dark_oak_planks
  - ~run lapex_map_hut def:<[world]>|231|65|-94|13|7|10|mossy_cobblestone|dark_oak_planks
  - ~run lapex_map_tower def:<[world]>|252|64|-108|16|green_concrete
  - ~run lapex_map_box def:<[world]>|217|65|-110|221|68|-106|barrel
  - ~run lapex_map_box def:<[world]>|226|65|-101|230|67|-97|mossy_cobblestone
  - ~run lapex_map_box def:<[world]>|212|65|-91|215|67|-87|barrel
  - ~run lapex_map_box def:<[world]>|198|61|-140|200|72|-138|mangrove_log
  - ~run lapex_map_box def:<[world]>|191|68|-147|207|70|-131|mangrove_leaves[persistent=true]
  - ~run lapex_map_box def:<[world]>|259|59|-91|261|70|-89|mangrove_log
  - ~run lapex_map_box def:<[world]>|252|66|-98|268|69|-82|mangrove_leaves[persistent=true]
  - ~run lapex_map_road def:<[world]>|225|64|-150|225|64|-139|5|mangrove_planks

lapex_map_poi_swamps:
  type: task
  debug: false
  definitions: world
  script:
  # Dense mangrove pools with a cross-shaped boardwalk and scattered shelters.
  - ~run lapex_map_pool def:<[world]>|219|55|126|18|12
  - ~run lapex_map_pool def:<[world]>|248|55|145|17|13
  - ~run lapex_map_pool def:<[world]>|258|54|116|11|8
  - ~run lapex_map_disc def:<[world]>|237|55|132|12|2|10|mud
  - ~run lapex_map_disc def:<[world]>|207|55|151|9|2|7|mud
  - ~run lapex_map_box def:<[world]>|196|58|132|272|59|136|mangrove_planks
  - ~run lapex_map_box def:<[world]>|233|58|101|237|59|166|mangrove_planks
  - ~run lapex_map_box def:<[world]>|215|54|133|217|57|135|mangrove_log
  - ~run lapex_map_box def:<[world]>|248|53|133|250|57|135|mangrove_log
  - ~run lapex_map_box def:<[world]>|234|53|151|236|57|153|mangrove_log
  - ~run lapex_map_hut def:<[world]>|198|59|116|13|7|11|mangrove_planks|mud_bricks
  - ~run lapex_map_hut def:<[world]>|246|59|126|14|7|11|mangrove_planks|mud_bricks
  - ~run lapex_map_hut def:<[world]>|213|59|148|13|7|10|mossy_cobblestone|mangrove_planks
  - ~run lapex_map_tower def:<[world]>|264|58|151|15|lime_concrete
  - ~run lapex_map_box def:<[world]>|226|59|128|230|62|131|barrel
  - ~run lapex_map_box def:<[world]>|241|59|138|244|61|142|mossy_cobblestone
  - ~run lapex_map_box def:<[world]>|204|55|104|206|71|106|mangrove_log
  - ~run lapex_map_box def:<[world]>|197|63|104|214|65|106|mangrove_log
  - ~run lapex_map_disc def:<[world]>|205|70|105|10|4|9|mangrove_leaves[persistent=true]
  - ~run lapex_map_box def:<[world]>|270|54|130|272|68|132|mangrove_log
  - ~run lapex_map_box def:<[world]>|264|62|123|278|64|139|mangrove_leaves[persistent=true]
  - ~run lapex_map_road def:<[world]>|235|58|91|235|58|101|5|mangrove_planks

lapex_map_poi_bridges:
  type: task
  debug: false
  definitions: world
  script:
  # Two-level canyon crossing with towers, under-deck routes, and hard cover.
  - ~run lapex_map_road def:<[world]>|-45|64|15|-18|71|15|9|smooth_stone
  - ~run lapex_map_road def:<[world]>|-18|71|15|91|71|15|11|smooth_stone
  - ~run lapex_map_road def:<[world]>|91|71|15|116|65|15|9|smooth_stone
  - ~run lapex_map_box def:<[world]>|-19|72|9|92|73|21|polished_andesite
  - ~run lapex_map_box def:<[world]>|-19|74|8|92|75|9|red_concrete
  - ~run lapex_map_box def:<[world]>|-19|74|21|92|75|22|red_concrete
  - ~run lapex_map_box def:<[world]>|5|52|7|10|84|10|stone_bricks
  - ~run lapex_map_box def:<[world]>|5|52|20|10|84|23|stone_bricks
  - ~run lapex_map_box def:<[world]>|62|52|7|67|84|10|stone_bricks
  - ~run lapex_map_box def:<[world]>|62|52|20|67|84|23|stone_bricks
  - ~run lapex_map_box def:<[world]>|3|81|5|12|85|25|red_concrete
  - ~run lapex_map_box def:<[world]>|60|81|5|69|85|25|red_concrete
  - ~run lapex_map_box def:<[world]>|12|82|13|60|84|17|red_concrete
  - ~run lapex_map_box def:<[world]>|-10|54|12|-6|70|18|stone_bricks
  - ~run lapex_map_box def:<[world]>|28|54|12|32|70|18|stone_bricks
  - ~run lapex_map_box def:<[world]>|79|54|12|83|70|18|stone_bricks
  - ~run lapex_map_road def:<[world]>|-14|61|29|87|61|29|5|dark_oak_planks
  - ~run lapex_map_box def:<[world]>|-18|55|26|-15|70|32|stone_bricks
  - ~run lapex_map_box def:<[world]>|27|53|26|32|60|32|stone_bricks
  - ~run lapex_map_box def:<[world]>|88|55|26|91|70|32|stone_bricks
  - ~run lapex_map_hut def:<[world]>|-31|71|-1|12|7|10|stone_bricks|red_concrete
  - ~run lapex_map_hut def:<[world]>|93|70|24|12|7|10|stone_bricks|red_concrete
  - ~run lapex_map_box def:<[world]>|18|74|11|23|77|14|iron_block
  - ~run lapex_map_box def:<[world]>|45|74|17|50|77|20|iron_block
  - ~run lapex_map_box def:<[world]>|32|67|12|38|67|18|smooth_stone
  - ~run lapex_map_stair def.world:<[world]> def.x:-22 def.y:73 def.z:15 def.rise:12 def.direction:east def.width:3 def.material:iron_block

lapex_map_poi_hydro_dam:
  type: task
  debug: false
  definitions: world
  script:
  # Massive dam wall, reservoir, turbine hall, and accessible spillway tunnels.
  - ~run lapex_map_pool def:<[world]>|207|68|25|31|43
  - ~run lapex_map_box def:<[world]>|168|53|-27|179|84|77|gray_concrete
  - ~run lapex_map_box def:<[world]>|166|84|-29|181|87|79|polished_andesite
  - ~run lapex_map_road def:<[world]>|173|87|-30|173|87|80|7|smooth_stone
  - ~run lapex_map_box def:<[world]>|168|59|-15|179|67|-7|air
  - ~run lapex_map_box def:<[world]>|168|59|20|179|67|28|air
  - ~run lapex_map_box def:<[world]>|168|59|55|179|67|63|air
  - ~run lapex_map_box def:<[world]>|175|68|-16|180|72|-6|blue_concrete
  - ~run lapex_map_box def:<[world]>|175|68|19|180|72|29|blue_concrete
  - ~run lapex_map_box def:<[world]>|175|68|54|180|72|64|blue_concrete
  - ~run lapex_map_hollow def:<[world]>|184|69|-14|214|81|12|light_gray_concrete|polished_andesite|gray_concrete
  - ~run lapex_map_box def:<[world]>|184|70|-5|186|75|3|air
  - ~run lapex_map_box def:<[world]>|198|70|12|204|75|14|air
  - ~run lapex_map_hollow def:<[world]>|132|56|2|165|71|49|stone_bricks|polished_andesite|gray_concrete
  - ~run lapex_map_box def:<[world]>|158|57|17|167|64|27|air
  - ~run lapex_map_box def:<[world]>|144|57|2|152|64|4|air
  - ~run lapex_map_box def:<[world]>|146|62|10|151|66|41|iron_block
  - ~run lapex_map_box def:<[world]>|155|62|10|160|66|41|iron_block
  - ~run lapex_map_box def:<[world]>|181|84|-25|190|87|-15|polished_andesite
  - ~run lapex_map_box def:<[world]>|181|84|65|190|87|75|polished_andesite
  - ~run lapex_map_tower def:<[world]>|185|88|-20|18|yellow_concrete
  - ~run lapex_map_tower def:<[world]>|185|88|70|18|yellow_concrete
  - ~run lapex_map_road def:<[world]>|119|61|25|165|84|25|7|smooth_stone
  - ~run lapex_map_box def:<[world]>|188|70|18|193|73|23|orange_concrete
  - ~run lapex_map_box def:<[world]>|196|70|18|201|72|23|iron_block
  - ~run lapex_map_box def:<[world]>|204|70|18|209|73|23|orange_concrete
  - ~run lapex_map_box def:<[world]>|181|71|21|189|71|29|polished_andesite

lapex_map_poi_market:
  type: task
  debug: false
  definitions: world
  script:
  # A circular covered bazaar with four entrances, roof access, and dense stalls.
  - ~run lapex_map_disc def:<[world]>|-30|63|120|31|2|31|stone_bricks
  - ~run lapex_map_disc def:<[world]>|-30|70|120|28|8|28|red_terracotta
  - ~run lapex_map_disc def:<[world]>|-30|70|120|24|6|24|air
  - ~run lapex_map_disc def:<[world]>|-30|64|120|27|1|27|smooth_stone
  - ~run lapex_map_disc def:<[world]>|-30|77|120|29|2|29|red_concrete
  - ~run lapex_map_disc def:<[world]>|-30|78|120|7|3|7|air
  - ~run lapex_map_box def:<[world]>|-35|65|91|-25|72|102|air
  - ~run lapex_map_box def:<[world]>|-35|65|138|-25|72|149|air
  - ~run lapex_map_box def:<[world]>|-60|65|115|-49|72|125|air
  - ~run lapex_map_box def:<[world]>|-11|65|115|0|72|125|air
  - ~run lapex_map_box def:<[world]>|-45|65|106|-39|68|111|yellow_concrete
  - ~run lapex_map_box def:<[world]>|-36|65|105|-29|68|110|orange_concrete
  - ~run lapex_map_box def:<[world]>|-22|65|106|-15|68|111|cyan_concrete
  - ~run lapex_map_box def:<[world]>|-46|65|128|-39|68|134|cyan_concrete
  - ~run lapex_map_box def:<[world]>|-34|65|130|-27|68|136|yellow_concrete
  - ~run lapex_map_box def:<[world]>|-21|65|128|-14|68|134|orange_concrete
  - ~run lapex_map_disc def:<[world]>|-30|65|120|8|1|8|polished_andesite
  - ~run lapex_map_box def:<[world]>|-34|66|116|-26|68|117|barrel
  - ~run lapex_map_box def:<[world]>|-34|66|123|-26|68|124|barrel
  - ~run lapex_map_box def:<[world]>|-34|66|118|-33|68|122|barrel
  - ~run lapex_map_box def:<[world]>|-27|66|118|-26|68|122|barrel
  - ~run lapex_map_box def:<[world]>|-32|67|118|-28|67|122|smooth_stone
  - ~run lapex_map_road def:<[world]>|-30|64|82|-30|64|101|7|red_sandstone
  - ~run lapex_map_road def:<[world]>|-30|64|139|-30|64|159|7|red_sandstone
  - ~run lapex_map_road def:<[world]>|-69|64|120|-50|64|120|7|red_sandstone
  - ~run lapex_map_road def:<[world]>|-10|64|120|10|64|120|7|red_sandstone
  - ~run lapex_map_tower def:<[world]>|-57|64|94|13|orange_concrete
  - ~run lapex_map_tower def:<[world]>|-4|64|145|13|orange_concrete
  - ~run lapex_map_stair def.world:<[world]> def.x:-77 def.y:64 def.z:120 def.rise:13 def.direction:east def.width:3 def.material:red_sandstone

lapex_map_poi_repulsor:
  type: task
  debug: false
  definitions: world
  script:
  # Military repulsor complex with a tall beacon, hangars, and landing apron.
  - ~run lapex_map_disc def:<[world]>|205|76|225|37|2|37|stone_bricks
  - ~run lapex_map_disc def:<[world]>|205|78|225|32|1|32|light_gray_concrete
  - ~run lapex_map_disc def:<[world]>|205|79|225|14|2|14|black_concrete
  - ~run lapex_map_tower def:<[world]>|205|79|210|43|red_concrete
  - ~run lapex_map_disc def:<[world]>|205|96|210|10|1|10|iron_block
  - ~run lapex_map_disc def:<[world]>|205|112|210|8|1|8|white_concrete
  - ~run lapex_map_box def:<[world]>|203|119|194|207|122|226|red_concrete
  - ~run lapex_map_box def:<[world]>|189|119|208|221|122|212|red_concrete
  - ~run lapex_map_box def:<[world]>|201|123|206|209|127|214|iron_block
  - ~run lapex_map_hollow def:<[world]>|162|78|201|192|91|228|gray_concrete|polished_andesite|light_gray_concrete
  - ~run lapex_map_box def:<[world]>|190|79|210|194|85|219|air
  - ~run lapex_map_box def:<[world]>|173|79|226|181|85|230|air
  - ~run lapex_map_hollow def:<[world]>|218|78|224|249|91|250|gray_concrete|polished_andesite|light_gray_concrete
  - ~run lapex_map_box def:<[world]>|216|79|234|220|85|243|air
  - ~run lapex_map_box def:<[world]>|231|79|222|239|85|226|air
  - ~run lapex_map_disc def:<[world]>|172|79|246|14|1|14|black_concrete
  - ~run lapex_map_disc def:<[world]>|172|80|246|10|1|10|smooth_stone
  - ~run lapex_map_box def:<[world]>|170|80|237|174|80|255|yellow_concrete
  - ~run lapex_map_tower def:<[world]>|241|79|204|18|red_concrete
  - ~run lapex_map_tower def:<[world]>|177|79|191|18|red_concrete
  - ~run lapex_map_road def:<[world]>|205|78|265|205|78|250|9|gray_concrete
  - ~run lapex_map_box def:<[world]>|194|79|247|199|82|252|orange_concrete
  - ~run lapex_map_box def:<[world]>|210|79|250|215|82|255|iron_block
  - ~run lapex_map_box def:<[world]>|220|79|203|225|82|208|orange_concrete

lapex_map_poi_water_treatment:
  type: task
  debug: false
  definitions: world
  script:
  # Treatment basins, filter plant, raised catwalks, and exposed pipe lanes.
  - ~run lapex_map_disc def:<[world]>|35|62|250|48|2|39|stone_bricks
  - ~run lapex_map_pool def:<[world]>|9|64|246|15|12
  - ~run lapex_map_pool def:<[world]>|43|64|250|15|12
  - ~run lapex_map_pool def:<[world]>|69|64|246|10|9
  - ~run lapex_map_pool def:<[world]>|9|64|274|13|9
  - ~run lapex_map_hollow def:<[world]>|20|64|207|51|78|230|light_gray_concrete|polished_andesite|gray_concrete
  - ~run lapex_map_box def:<[world]>|31|65|228|39|71|232|air
  - ~run lapex_map_box def:<[world]>|49|65|214|53|71|222|air
  - ~run lapex_map_hollow def:<[world]>|55|64|262|78|75|281|gray_concrete|polished_andesite|light_gray_concrete
  - ~run lapex_map_box def:<[world]>|53|65|268|57|70|275|air
  - ~run lapex_map_box def:<[world]>|-9|68|232|80|69|235|iron_block
  - ~run lapex_map_box def:<[world]>|24|68|233|27|69|273|iron_block
  - ~run lapex_map_box def:<[world]>|58|68|233|61|69|265|iron_block
  - ~run lapex_map_box def:<[world]>|7|64|233|10|67|236|stone_bricks
  - ~run lapex_map_box def:<[world]>|41|64|233|44|67|236|stone_bricks
  - ~run lapex_map_box def:<[world]>|67|64|233|70|67|236|stone_bricks
  - ~run lapex_map_box def:<[world]>|-4|70|251|18|73|254|blue_concrete
  - ~run lapex_map_box def:<[world]>|34|70|251|56|73|254|blue_concrete
  - ~run lapex_map_box def:<[world]>|65|69|251|82|72|254|blue_concrete
  - ~run lapex_map_box def:<[world]>|16|66|260|21|69|265|orange_concrete
  - ~run lapex_map_box def:<[world]>|32|66|265|37|69|270|iron_block
  - ~run lapex_map_box def:<[world]>|46|66|237|51|69|242|orange_concrete
  - ~run lapex_map_tower def:<[world]>|-8|64|288|18|cyan_concrete
  - ~run lapex_map_road def:<[world]>|35|64|191|35|64|207|8|smooth_stone
  - ~run lapex_map_road def:<[world]>|35|64|282|35|64|300|8|smooth_stone
  - ~run lapex_map_box def:<[world]>|31|67|246|39|67|254|polished_andesite
  - ~run lapex_map_stair def.world:<[world]> def.x:-20 def.y:64 def.z:233 def.rise:5 def.direction:east def.width:3 def.material:iron_block
