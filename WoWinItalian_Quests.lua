-- Addon: WoWinItalian_Quests (version: 9.01) 2020.11.18
-- Opis: AddOn displays quests in Italian independently from realm language.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Addon project page: https://panel.wowpopolsku.pl/quest_collector.php

-- Zmienne lokalne
local QTR_version = GetAddOnMetadata("WoWinItalian_Quests", "Version");
local QTR_onDebug = false;      
local QTR_locale = GetLocale();
local QTR_name = UnitName("player");
local QTR_sex  = UnitSex("player");
local QTR_class= UnitClass("player");
local QTR_race = UnitRace("player");
local QTR_waitTable = {};
local QTR_waitFrame = nil;
local QTR_MessOrig = {
      details    = "Description", 
      objectives = "Objectives", 
      rewards    = "Rewards", 
      itemchoose0= "You will receive:",
      itemchoose1= "You will be able to choose one of these rewards:", 
      itemchoose2= "Choose one of these rewards:", 
      itemchoose3= "You receiving the reward:",
      itemreceiv0= "You will receive:",
      itemreceiv1= "You will also receive:", 
      itemreceiv2= "You receiving the reward:", 
      itemreceiv3= "You also receiving the reward:",
      learnspell = "Learn Spell:", 
      reqmoney   = "Required Money:", 
      reqitems   = "Required items:", 
      experience = "Experience:", 
      currquests = "Current Quests", 
      avaiquests = "Available Quests", 
      reward_aura      = "The following will be cast on you:", 
      reward_spell     = "You will learn the following:", 
      reward_companion = "You will gain these Companions:", 
      reward_follower  = "You will gain these followers:", 
      reward_reputation= "Reputation awards:", 
      reward_title     = "You shall be granted the title:", 
      reward_tradeskill= "You will learn how to create::", 
      reward_unlock    = "You will unlock access to the following:", 
      reward_bonus     = "Completing this quest while in Party Sync may reward:", 
      };
local QTR_orig_table = {};
local QTR_quest_EN = {
      id = 0,
      title = "",
      details = "",
      objectives = "",
      progress = "",
      completion = "",
      itemchoose = "",
      itemreceive = "", };      
local QTR_quest_LG = {
      id = 0,
      title = "",
      details = "",
      objectives = "",
      progress = "",
      completion = "",
      itemchoose = "",
      itemreceive = "", };      
local last_time = GetTime();
local last_text = 0;
local curr_trans = "1";
local _font1, _size1, _31 = getglobal("QuestInfoTitleHeader"):GetFont();
local _font2, _size2, _32 = getglobal("QuestInfoDescriptionText"):GetFont();
local Original_Font1 = _font1;
local Original_Font2 = _font2;
local p_race = {
      [1] = { enUS = "Blood Elf", deDE2="Blutelf", deDE3="Blutelfe", frFR2="Elfe de sang", frFR3="Elfe de sang", esES2="Elfo de sangre", esES3="Elfa de sangre", itIT2="Elfo del Sangue", itIT3="Elfa del Sangue", ptBR2="Elfo Sangrento", ptBR3IT="Elfa Sangrenta", ruRU2="Эльф крови", ruRU3="Эльфийка крови" }, 
      [2] = { enUS = "Dark Iron Dwarf", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [3] = { enUS = "Draenei", deDE2="Draenei", deDE3="Draenei", frFR2="Draenei", frFR3="Draenei", esES2="Draenei", esES3="Draenei", itIT2="Draenei", itIT3="Draenei", ptBR2="Draenei", ptBR3IT="Draeneia", ruRU2="Дреней", ruRU3="Дренейка" },
      [4] = { enUS = "Dwarf", deDE2="Zwerg", deDE3="Zwergin", frFR2="Nain", frFR3="Naine", esES2="Enano", esES3="Enana", itIT2="Nano", itIT3="Nana", ptBR2="Anão", ptBR3IT="Anã", ruRU2="Дворф", ruRU3="Дворфийка" },
      [5] = { enUS = "Gnome", deDE2="Gnom", deDE3="Gnom", frFR2="Gnome", frFR3="Gnome", esES2="Gnomo", esES3="Gnoma", itIT2="Gnomo", itIT3="Gnoma", ptBR2="Gnomo", ptBR3IT="Gnomida", ruRU2="Гном", ruRU3="Гномка" },
      [6] = { enUS = "Goblin", deDE2="Goblin", deDE3="Goblin", frFR2="Gobelin", frFR3="Gobeline", esES2="Goblin", esES3="Goblin", itIT2="Goblin", itIT3="Goblin", ptBR2="Goblin", ptBR3IT="Goblina", ruRU2="Гоблин", ruRU3="Гоблин" },
      [7] = { enUS = "Highmountain Tauren", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [8] = { enUS = "Human", deDE2="Mensch", deDE3="Mensch", frFR2="Humain", frFR3="Humaine", esES2="Humano", esES3="Humana", itIT2="Omano", itIT3="Umana", ptBR2="Humano", ptBR3IT="Humana", ruRU2="Человек", ruRU3="Человек" },
      [9] = { enUS = "Kul Tiran Human", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [10] = { enUS = "Lightforged Draenei", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [11] = { enUS = "Mag'har Orc", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [12] = { enUS = "Nightborne", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [13] = { enUS = "Night Elf", deDE2="Nachtelf", deDE3="Nachtelfe", frFR2="Elfe de la nuit", frFR3="Elfe de la nuit", esES2="Elfo de la noche", esES3="Elfa de la noche", itIT2="Elfo della Notte", itIT3="Elfa della Notte", ptBR2="Elfo Noturno", ptBR3IT="Elfa Noturna", ruRU2="Ночной эльф", ruRU3="Ночная эльфийка" },
      [14] = { enUS = "Orc", deDE2="Orc", deDE3="Orc", frFR2="Orc", frFR3="Orque", esES2="Orco", esES3="Orco", itIT2="Orco", itIT3="Orchessa", ptBR2="Orc", ptBR3IT="Orquisa", ruRU2="Орк", ruRU3="Орчиха" },
      [15] = { enUS = "Pandaren", deDE2="Pandaren", deDE3="Pandaren", frFR2="Pandaren", frFR3="Pandarène", esES2="Pandaren", esES3="Pandaren", itIT2="Pandaren", itIT3="Pandaren", ptBR2="Pandaren", ptBR3IT="Pandarena", ruRU2="", ruRU3="" },
      [16] = { enUS = "Tauren", deDE2="Tauren", deDE3="Tauren", frFR2="Tauren", frFR3="Taurène", esES2="Tauren", esES3="Tauren", itIT2="Tauren", itIT3="Tauren", ptBR2="Tauren", ptBR3IT="Taurena", ruRU2="Таурен", ruRU3="Тауренка" },
      [17] = { enUS = "Troll", deDE2="Troll", deDE3="Troll", frFR2="Troll", frFR3="Trollesse", esES2="Trol", esES3="Trol", itIT2="Troll", itIT3="Troll", ptBR2="Troll", ptBR3IT="Trolesa", ruRU2="Тролль", ruRU3="Тролль" },
      [18] = { enUS = "Undead", deDE2="Untoter", deDE3="Untote", frFR2="Mort-vivant", frFR3="Moort-vivante", esES2="No-muerto", esES3="No-muerta", itIT2="Non Morto", itIT3="Non Morta", ptBR2="Morto-vivo", ptBR3IT="Morto-viva", ruRU2="Нежить", ruRU3="Нежить" },
      [19] = { enUS = "Void Elf", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" },
      [20] = { enUS = "Worgen", deDE2="Worgen", deDE3="Wergen", frFR2="Worgen", frFR3="Worgen", esES2="Huargen", esES3="Huargen", itIT2="Worgen", itIT3="Worgen", ptBR2="Worgen", ptBR3IT="Worgerin", ruRU2="Ворген", ruRU3="Ворген" },
      [21] = { enUS = "Zandalari Troll", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="", ruRU3="" } }
local p_class = {
      [1] = { enUS = "Death Knight", deDE2="Todesrichter", deDE3="Todesrichter", frFR2="Chavalier de la mort", frFR3="Chavalier de la mort", esES2="Caballero de la Muerte", esES3="Caballero de la Muerte", itIT2="Cavaliere della Morte", itIT3="Cavaliere della Morte", ptBR2="Cavaliero da Morte", ptBR3IT="Cavaleira da Morte", ruRU2="Рыцарь смерти", ruRU3="Рыцарь смерти" },
      [2] = { enUS = "Demon Hunter", deDE2="", deDE3="", frFR2="", frFR3="", esES2="", esES3="", itIT2="", itIT3="", ptBR2="", ptBR3IT="", ruRU2="Охотник на демонов", ruRU3="Охотница на демонов" },
      [3] = { enUS = "Druid", deDE2="Druide", deDE3="Druidin", frFR2="Druide", frFR3="Druidesse", esES2="Druido", esES3="Driuda", itIT2="Druido", itIT3="Druida", ptBR2="Druida", ptBR3IT="Druidesa", ruRU2="Друид", ruRU3="Друид" },
      [4] = { enUS = "Hunter", deDE2="Jäger", deDE3="Jägerin", frFR2="Chasseur", frFR3="Chasseresse", esES2="Cazador", esES3="Cazadora", itIT2="Cacciotore", itIT3="Cacciotrice", ptBR2="Caçador", ptBR3IT="Caçadora", ruRU2="Охотник", ruRU3="Охотница" },
      [5] = { enUS = "Mage", deDE2="Magier", deDE3="Magierin", frFR2="Mage", frFR3="Mage", esES2="Mago", esES3="Maga", itIT2="Mago", itIT3="Maga", ptBR2="Mago", ptBR3IT="Maga", ruRU2="Маг", ruRU3="Маг" },
      [6] = { enUS = "Monk", deDE2="Mönch", deDE3="Mönch", frFR2="Moine", frFR3="Moniale", esES2="Monje", esES3="Monje", itIT2="Monaco", itIT3="Monaca", ptBR2="Monge", ptBR3IT="Monja", ruRU2="Монах", ruRU3="Монахиня" },
      [7] = { enUS = "Paladin", deDE2="Paladin", deDE3="Paladin", frFR2="Paladin", frFR3="Paladin", esES2="Paladin", esES3="Paladin", itIT2="Paladino", itIT3="Paladina", ptBR2="Paladino", ptBR3IT="Paladina", ruRU2="Паладин", ruRU3="Паладин" },
      [8] = { enUS = "Priest", deDE2="Priester", deDE3="Priesterin", frFR2="Prêtre", frFR3="Prêtresse", esES2="Sacerdote", esES3="Sacerdotisa", itIT2="Sacerdote", itIT3="Sacerdotessa", ptBR2="Sacerdote", ptBR3IT="Sacerdotisa", ruRU2="Жрец", ruRU3="Жрица" },
      [9] = { enUS = "Rogue", deDE2="Schurke", deDE3="Schurin", frFR2="Voleur", frFR3="Voleuse", esES2="Picaro", esES3="Picara", itIT2="Ladro", itIT3="Ladra", ptBR2="Ladino", ptBR3IT="Ladina", ruRU2="Разгойник", ruRU3="Разгойница" },
      [10] = { enUS = "Shaman", deDE2="Schamane", deDE3="Schamanin", frFR2="Chaman", frFR3="Chamane", esES2="Chamán", esES3="Chamán", itIT2="Sciamano", itIT3="Sciamana", ptBR2="Xamã", ptBR3IT="Xamã", ruRU2="Шаман", ruRU3="Шаманка" },
      [11] = { enUS = "Warlock", deDE2="Hexenmaister", deDE3="Hexenmaisterin", frFR2="Démoniste", frFR3="Démoniste", esES2="Brujo", esES3="Bruja", itIT2="Stregone", itIT3="Strega", ptBR2="Bruxo", ptBR3IT="Bruxa", ruRU2="Чернокнижник", ruRU3="Чернокнижница" },
      [12] = { enUS = "Warrior", deDE2="Krieger", deDE3="Kriegerin", frFR2="Guerrier", frFR3="Guerrière", esES2="Guerrero", esES3="Guerrera", itIT2="Guerrino", itIT3="Guerrina", ptBR2="Guerreito", ptBR3IT="Guerreita", ruRU2="Воин", ruRU3="Воин" } }

if (QTR_locale=="enUS") then
   if (QTR_sex==2) then     -- Male
      for i=1,21 do
         if (p_race[i].enUS == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU2;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES2;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR2;
            else
               player_race = p_race[i].enUS;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].enUS == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU2;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES2;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR2;
            else
               player_class = p_class[i].enUS;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].enUS == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU3;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES3;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR3;
            else
               player_race = p_race[i].enUS;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].enUS == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU3;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES3;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR3;
            else
               player_class = p_class[i].enUS;
            end
            break;
         end
      end
   end
elseif (QTR_locale=="deDE") then
   if (QTR_sex==2) then      -- Male
      for i=1,21 do
         if (p_race[i].deDE2 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES2;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR2;
            else
               player_race = p_race[i].deDE2;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].deDE2 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES2;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR2;
            else
               player_class = p_class[i].deDE2;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].deDE3 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES3;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR3;
            else
               player_race = p_race[i].deDE3;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].deDE3 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES3;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR3;
            else
               player_class = p_class[i].deDE3;
            end
            break;
         end
      end
   end
elseif (QTR_locale=="frFR") then
   if (QTR_sex==2) then      -- Male
      for i=1,21 do
         if (p_race[i].frFR2 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE2;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES2;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR2;
            else
               player_race = p_race[i].frFR2;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].frFR2 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE2;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES2;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR2;
            else
               player_class = p_class[i].frFR2;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].frFR3 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE3;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES3;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR3;
            else
               player_race = p_race[i].frFR3;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].frFR3 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE3;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES3;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR3;
            else
               player_class = p_class[i].frFR3;
            end
            break;
         end
      end
   end
elseif (QTR_locale=="esES") then
   if (QTR_sex==2) then      -- Male
      for i=1,21 do
         if (p_race[i].esES2 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR2;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR2;
            else
               player_race = p_race[i].esES2;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].esES2 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR2;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT2;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR2;
            else
               player_class = p_class[i].esES2;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].esES3 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR3;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR3;
            else
               player_race = p_race[i].esES3;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].esES3 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR3;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT3;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR3;
            else
               player_class = p_class[i].esES3;
            end
            break;
         end
      end
   end
elseif (QTR_locale=="itIT") then
   if (QTR_sex==2) then      -- Male
      for i=1,21 do
         if (p_race[i].itIT2 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES2;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR2;
            else
               player_race = p_race[i].itIT2;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].itIT2 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES2;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR2;
            else
               player_class = p_class[i].itIT2;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].itIT3 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES3;
            elseif (QTR_lang=="PT") then
               player_race = p_race[i].ptBR3;
            else
               player_race = p_race[i].itIT3;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].itIT3 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES3;
            elseif (QTR_lang=="PT") then
               player_class = p_class[i].ptBR3;
            else
               player_class = p_class[i].itIT3;
            end
            break;
         end
      end
   end
elseif (QTR_locale=="ptBR") then
   if (QTR_sex==2) then      -- Male
      for i=1,21 do
         if (p_race[i].itIT2 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES2;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT2;
            else
               player_race = p_race[i].ptBR2;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].ptBR2 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU2;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES2;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT2;
            else
               player_class = p_class[i].ptBR2;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].ptBR3 == QTR_race) then
            if (QTR_lang=="RU") then
               player_race = p_race[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES3;
            elseif (QTR_lang=="IT") then
               player_race = p_race[i].itIT3;
            else
               player_race = p_race[i].ptBR3;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].ptBR3 == QTR_class) then
            if (QTR_lang=="RU") then
               player_class = p_class[i].ruRU3;
            elseif (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES3;
            elseif (QTR_lang=="IT") then
               player_class = p_class[i].itIT3;
            else
               player_class = p_class[i].ptBR3;
            end
            break;
         end
      end
   end
elseif (QTR_locale=="ruRU") then
   if (QTR_sex==2) then      -- Male
      for i=1,21 do
         if (p_race[i].ruRU2 == QTR_race) then
            if (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES2;
            else
               player_race = p_race[i].ruRU2;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].ruRU2 == QTR_class) then
            if (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE2;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR2;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES2;
            else
               player_class = p_class[i].ruRU2;
            end
            break;
         end
      end
   else              -- Female
      for i=1,21 do
         if (p_race[i].ruRU3 == QTR_race) then
            if (QTR_lang=="EN") then
               player_race = p_race[i].enUS;
            elseif (QTR_lang=="DE") then
               player_race = p_race[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_race = p_race[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_race = p_race[i].esES3;
            else
               player_race = p_race[i].ruRU3;
            end
            break;
         end
      end
      for i=1,12 do
         if (p_class[i].ruRU3 == QTR_class) then
            if (QTR_lang=="EN") then
               player_class = p_class[i].enUS;
            elseif (QTR_lang=="DE") then
               player_class = p_class[i].deDE3;
            elseif (QTR_lang=="FR") then
               player_class = p_class[i].frFR3;
            elseif (QTR_lang=="ES") then
               player_class = p_class[i].esES3;
            else
               player_class = p_class[i].ruRU3;
            end
            break;
         end
      end
   end
else
   player_race = QTR_race;
   player_class= QTR_class;
end


-- Zmienne programowe zapisane na stałe na komputerze
function QTR_CheckVars()
  if (not QTR_PS) then
     QTR_PS = {};
  end
  if (not QTR_SAVED) then
     QTR_SAVED = {};
  end
  -- inicjalizacja: tłumaczenia włączone
  if (not QTR_PS["active"]) then
     QTR_PS["active"] = "1";
  end
  -- inicjalizacja: tłumaczenie tytułu questu włączone
  if (not QTR_PS["transtitle"] ) then
     QTR_PS["transtitle"] = "1";   
  end
  if (not QTR_PS["showbutton"] ) then
     QTR_PS["showbutton"] = "1";   
  end
  -- zmienna specjalna dostępności funkcji GetQuestID 
  if ( QTR_PS["isGetQuestID"] ) then
     isGetQuestID=QTR_PS["isGetQuestID"];
  end;
end


-- Sprawdza dostępność funkcji specjalnej Wow'a: GetQuestID()
function DetectEmuServer()
  QTR_PS["isGetQuestID"]="0";
  isGetQuestID="0";
  -- funkcja GetQuestID() występuje tylko na serwerach Blizzarda
  if ( GetQuestID() ) then
     QTR_PS["isGetQuestID"]="1";
     isGetQuestID="1";
  end
end


-- Obsługa komend slash
function QTR_SlashCommand(msg)
   if (msg=="on" or msg=="ON" or msg=="1") then
      if (QTR_PS["active"]=="1") then
         print ("QTR - "..QTR_Interface.is_on);
      else
         print ("|cffffff00QTR - "..QTR_Interface.turn_on);
         QTR_PS["active"] = "1";
         QTR_ToggleButton0:Enable();
         QTR_ToggleButton1:Enable();
         QTR_ToggleButton2:Enable();
         QTR_Translate_On(1);
      end
   elseif (msg=="off" or msg=="OFF" or msg=="0") then
      if (QTR_PS["active"]=="0") then
         print ("QTR - "..QTR_Interface.is_off);
      else
         print ("|cffffff00QTR - "..QTR_Interface.turn_off);
         QTR_PS["active"] = "0";
         QTR_ToggleButton0:Disable();
         QTR_ToggleButton1:Disable();
         QTR_ToggleButton2:Disable();
         QTR_Translate_Off(1);
      end
   elseif (msg=="title on" or msg=="TITLE ON" or msg=="title 1") then
      if (QTR_PS["transtilte"]=="1") then
         print ("QTR - "..QTR_Interface.title_is_on);
      else
         print ("|cffffff00QTR - "..QTR_Interface.title_turn_on);
         QTR_PS["transtitle"] = "1";
         QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
      end
   elseif (msg=="title off" or msg=="TITLE OFF" or msg=="title 0") then
      if (QTR_PS["transtilte"]=="0") then
         print ("QTR - "..QTR_Interface.title_is_off);
      else
         print ("|cffffff00QTR - "..QTR_Interface.title_turn_off);
         QTR_PS["transtitle"] = "0";
         QuestInfoTitleHeader:SetFont(Original_Font1, 18);
      end
   elseif (msg=="title" or msg=="TITLE") then
      if (QTR_PS["transtilte"]=="1") then
         print ("QTR - "..QTR_Interface.title_is_on);
      else
         print ("QTR - "..QTR_Interface.title_is_off);
      end
   elseif (msg=="") then
      InterfaceOptionsFrame_Show();
      InterfaceOptionsFrame_OpenToCategory("WoWinItalian-Quests");
   else
      print (QTR_Interface.quick_menu);
   end
end


function QTR_SetCheckButtonState()
  QTRCheckButton0:SetChecked(QTR_PS["active"]=="1");
  QTRCheckButton3:SetChecked(QTR_PS["transtitle"]=="1");
  QTRCheckButton5:SetChecked(QTR_PS["showbutton"]=="1");
end


function QTR_BlizzardOptions()
  -- Create main frame for information text
  local QTROptions = CreateFrame("FRAME", "WoWinItalian_Quests_Options");
  QTROptions.name = "WoWinItalian-Quests";
  QTROptions.refresh = function (self) QTR_SetCheckButtonState() end;
  InterfaceOptions_AddCategory(QTROptions);

  local QTROptionsHeader = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsHeader:SetFontObject(GameFontNormalLarge);
  QTROptionsHeader:SetJustifyH("LEFT"); 
  QTROptionsHeader:SetJustifyV("TOP");
  QTROptionsHeader:ClearAllPoints();
  QTROptionsHeader:SetPoint("TOPLEFT", 16, -16);
  QTROptionsHeader:SetText("WoWinItalian-Quests, ver. "..QTR_version.." ("..QTR_lang..") "..QTR_date.. " ("..QTR_base..") by Platine © 2020");

  local QTRCheckButton0 = CreateFrame("CheckButton", "QTRCheckButton0", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton0:SetPoint("TOPLEFT", QTROptionsHeader, "BOTTOMLEFT", 0, -50);
  QTRCheckButton0:SetScript("OnClick", function(self) if (QTR_PS["active"]=="1") then QTR_PS["active"]="0" else QTR_PS["active"]="1" end; end);
  QTRCheckButton0Text:SetFont(QTR_Font2, 13);
  QTRCheckButton0Text:SetText(QTR_Interface.active);

  local QTROptionsMode1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsMode1:SetFontObject(GameFontWhite);
  QTROptionsMode1:SetJustifyH("LEFT");
  QTROptionsMode1:SetJustifyV("TOP");
  QTROptionsMode1:ClearAllPoints();
  QTROptionsMode1:SetPoint("TOPLEFT", QTRCheckButton0, "BOTTOMLEFT", 30, -20);
  QTROptionsMode1:SetFont(QTR_Font2, 13);
  QTROptionsMode1:SetText(QTR_Interface.options1);
  
  local QTRCheckButton3 = CreateFrame("CheckButton", "QTRCheckButton3", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton3:SetPoint("TOPLEFT", QTROptionsMode1, "BOTTOMLEFT", 0, -5);
  QTRCheckButton3:SetScript("OnClick", function(self) if (QTR_PS["transtitle"]=="0") then QTR_PS["transtitle"]="1" else QTR_PS["transtitle"]="0" end; end);
  QTRCheckButton3Text:SetFont(QTR_Font2, 13);
  QTRCheckButton3Text:SetText(QTR_Interface.transtitle);

  local QTRCheckButton5 = CreateFrame("CheckButton", "QTRCheckButton5", QTROptions, "OptionsCheckButtonTemplate");
  QTRCheckButton5:SetPoint("TOPLEFT", QTRCheckButton3, "BOTTOMLEFT", 0, -20);
  QTRCheckButton5:SetScript("OnClick", function(self) if (QTR_PS["showbutton"]=="0") then QTR_PS["showbutton"]="1" else QTR_PS["showbutton"]="0" end; end);
  QTRCheckButton5Text:SetFont(QTR_Font2, 13);
  QTRCheckButton5Text:SetText(QTR_Interface.ShowButton);

  local QTRSlachCommand = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRSlachCommand:SetFontObject(GameFontWhite);
  QTRSlachCommand:SetJustifyH("LEFT"); 
  QTRSlachCommand:SetJustifyV("TOP");
  QTRSlachCommand:ClearAllPoints();
  QTRSlachCommand:SetPoint("TOPLEFT", QTRCheckButton5, "BOTTOMLEFT", -20, -60);
  QTRSlachCommand:SetText(QTR_Interface.SlashComm.." /qtr-quests  o  /qtrq ");
  QTRSlachCommand:SetFont(QTR_Font2, 14);

  local QTRWWW1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRWWW1:SetFontObject(GameFontWhite);
  QTRWWW1:SetJustifyH("LEFT");
  QTRWWW1:SetJustifyV("TOP");
  QTRWWW1:ClearAllPoints();
  QTRWWW1:SetPoint("BOTTOMLEFT", 16, 16);
  QTRWWW1:SetFont(QTR_Font2, 13);
  QTRWWW1:SetText(QTR_Interface.WWW1);
  
  local QTRWWW2 = CreateFrame("EditBox", "QTRWWW2", QTROptions, "InputBoxTemplate");
  QTRWWW2:ClearAllPoints();
  QTRWWW2:SetPoint("TOPLEFT", QTRWWW1, "TOPRIGHT", 10, 4);
  QTRWWW2:SetHeight(20);
  QTRWWW2:SetWidth(315);
  QTRWWW2:SetAutoFocus(false);
  QTRWWW2:SetFontObject(GameFontGreen);
  QTRWWW2:SetText(QTR_Interface.WWW2);
  QTRWWW2:SetCursorPosition(0);
  QTRWWW2:SetScript("OnEnter", function(self)
	  GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
      getglobal("GameTooltipTextLeft1"):SetFont(QTR_Font2, 13);
  	  GameTooltip:SetText(QTR_Interface.WWW3, nil, nil, nil, nil, true);
	  GameTooltip:Show() --Show the tooltip
     end);
  QTRWWW2:SetScript("OnLeave", function(self)
      getglobal("GameTooltipTextLeft1"):SetFont(Original_Font2, 13);
	  GameTooltip:Hide() --Hide the tooltip
     end);
  QTRWWW2:SetScript("OnTextChanged", function(self) QTRWWW2:SetText(QTR_Interface.WWW2); end);
  
end


function QTR_SaveQuest(event)          -- nie zapisujemy nic w tym dodatku
end


function QTR_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(QTR_waitFrame == nil) then
    QTR_waitFrame = CreateFrame("Frame","QTR_WaitFrame", UIParent);
    QTR_waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #QTR_waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(QTR_waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(QTR_waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(QTR_waitTable,{delay,func,{...}});
  return true;
end


function QTR_ON_OFF()
   if (curr_trans=="1") then
      curr_trans="0";
      QTR_Translate_Off(1);
   else   
      curr_trans="1";
      QTR_Translate_On(1);
   end
end


-- Pierwsza funkcja wywoływana po załadowaniu dodatku
function QTR_OnLoad()
   QTR = CreateFrame("Frame");
   QTR:SetScript("OnEvent", QTR_OnEvent);
   QTR:RegisterEvent("ADDON_LOADED");
   QTR:RegisterEvent("QUEST_ACCEPTED");
   QTR:RegisterEvent("QUEST_DETAIL");
   QTR:RegisterEvent("QUEST_PROGRESS");
   QTR:RegisterEvent("QUEST_COMPLETE");
--   QTR:RegisterEvent("QUEST_FINISHED");
--   QTR:RegisterEvent("QUEST_GREETING");

   -- przycisk z nr ID questu w QuestFrame (NPC)
   QTR_ToggleButton0 = CreateFrame("Button",nil, QuestFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton0:SetWidth(170);
   QTR_ToggleButton0:SetHeight(20);
   QTR_ToggleButton0:SetText("Quest ID=?");
   QTR_ToggleButton0:Show();
   QTR_ToggleButton0:ClearAllPoints();
   QTR_ToggleButton0:SetPoint("TOPLEFT", QuestFrame, "TOPLEFT", 92, -25);
   QTR_ToggleButton0:SetScript("OnClick", QTR_ON_OFF);
   
   -- przycisk z nr ID questu w QuestLogPopupDetailFrame
   QTR_ToggleButton1 = CreateFrame("Button",nil, QuestLogPopupDetailFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton1:SetWidth(170);
   QTR_ToggleButton1:SetHeight(20);
   QTR_ToggleButton1:SetText("Quest ID=?");
   QTR_ToggleButton1:Show();
   QTR_ToggleButton1:ClearAllPoints();
   QTR_ToggleButton1:SetPoint("TOPLEFT", QuestLogPopupDetailFrame, "TOPLEFT", 40, -31);
   QTR_ToggleButton1:SetScript("OnClick", QTR_ON_OFF);

   -- przycisk z nr ID questu w QuestMapDetailsScrollFrame
   QTR_ToggleButton2 = CreateFrame("Button",nil, QuestMapDetailsScrollFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton2:SetWidth(170);
   QTR_ToggleButton2:SetHeight(20);
   QTR_ToggleButton2:SetText("Quest ID=?");
   QTR_ToggleButton2:Show();
   QTR_ToggleButton2:ClearAllPoints();
   QTR_ToggleButton2:SetPoint("TOPLEFT", QuestMapDetailsScrollFrame, "TOPLEFT", 105, 29);
   QTR_ToggleButton2:SetScript("OnClick", QTR_ON_OFF);

   -- funkcja wywoływana po kliknięciu na nazwę questu w QuestTracker   
   hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", QTR_PrepareReload);
   
   -- funkcja wywoływana po kliknięciu na nazwę questu w QuestMapFrame
   hooksecurefunc("QuestMapFrame_ShowQuestDetails", QTR_PrepareReload);
   
end


-- Określa aktualny numer ID questu z różnych metod
function QTR_GetQuestID()
   
   quest_ID = QuestMapFrame.DetailsFrame.questID;
   
   if (quest_ID==nil) then
      quest_ID = QuestLogPopupDetailFrame.questID;
   end
   
   if (quest_ID==nil) then
      if ( isGetQuestID=="1" ) then
         quest_ID = GetQuestID();
      end
   end         
   
   if (quest_ID==nil) then
      quest_ID = 0;
   end   

   return (quest_ID);
end



-- Wywoływane przy przechwytywanych zdarzeniach
function QTR_OnEvent(self, event, name, ...)
   if (event=="ADDON_LOADED" and name=="WoWinItalian_Quests") then
      SlashCmdList["WOWINITALIAN_QUESTS"] = function(msg) QTR_SlashCommand(msg); end
      SLASH_WOWINITALIAN_QUESTS1 = "/qtr-quests";
      SLASH_WOWINITALIAN_QUESTS2 = "/qtrq";
      QTR_CheckVars();
      -- twórz interface Options w Blizzard-Interface-Addons
      QTR_BlizzardOptions();
      print ("|cffffff00WoWinItalian-Quests ver. "..QTR_version.." ("..QTR_lang..") - "..QTR_Messages.loaded);
      QTR:UnregisterEvent("ADDON_LOADED");
      QTR.ADDON_LOADED = nil;
      if (not isGetQuestID) then
         DetectEmuServer();
      end
   elseif (event=="QUEST_DETAIL" or event=="QUEST_PROGRESS" or event=="QUEST_COMPLETE") then
      if ( QuestFrame:IsVisible() ) then
         QTR_QuestPrepare(event);
      end	-- QuestFrame is Visible
   end
end


-- Otworzono okienko QuestLogPopupDetailFrame lub QuestMapDetailsScrollFrame
function QTR_QuestPrepare(zdarzenie)
   if (QTR_PS["showbutton"]=="1") then
      QTR_ToggleButton0:Show();
      QTR_ToggleButton1:Show();
      QTR_ToggleButton2:Show();
   else
      QTR_ToggleButton0:Hide();
      QTR_ToggleButton1:Hide();
      QTR_ToggleButton2:Hide();
   end
   q_ID = QTR_GetQuestID();
   str_ID = tostring(q_ID);
   QTR_quest_EN.id = q_ID;
   QTR_quest_LG.id = q_ID;
   if ( QTR_PS["active"]=="1" ) then	-- tłumaczenia włączone
      QTR_ToggleButton0:Enable();
      QTR_ToggleButton1:Enable();
      QTR_ToggleButton2:Enable();
      curr_trans = "1";
      if ( QTR_QuestData[str_ID] ) then   -- wyświetlaj tylko, gdy istnieje tłumaczenie
         QTR_quest_LG.title = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Title"]);
         if (not QTR_orig_table[str_ID]) then
            QTR_orig_table[str_ID] = {};
         end
         if (not QTR_orig_table[str_ID].title) then        
            QTR_quest_EN.title = GetTitleText();
            if (QTR_quest_EN.title=="") then
               QTR_quest_EN.title=QuestInfoTitleHeader:GetText();
            end
            QTR_orig_table[str_ID].title = QTR_quest_EN.title;
         else
            QTR_quest_EN.title = QTR_orig_table[str_ID].title;
         end
         QTR_quest_LG.details = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Description"]);
         QTR_quest_LG.objectives = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Objectives"]);
         if (QTR_quest_LG.details=="") then
            QTR_quest_LG.details = "("..QTR_Messages.missing..")";
         end
         if (QTR_quest_LG.objectives=="") then
            QTR_quest_LG.objectives = "("..QTR_Messages.missing..")";
         end
         if (zdarzenie=="QUEST_DETAIL") then
            if (not QTR_orig_table[str_ID].details) then        
               QTR_quest_EN.details = GetQuestText();
               QTR_orig_table[str_ID].details = QTR_quest_EN.details;
            else
               QTR_quest_EN.details = QTR_orig_table[str_ID].details;
            end
            if (not QTR_orig_table[str_ID].objectives) then        
               QTR_quest_EN.objectives = GetObjectiveText();
               QTR_orig_table[str_ID].objectives = QTR_quest_EN.objectives;
            else
               QTR_quest_EN.objectives = QTR_orig_table[str_ID].objectives;
            end
            QTR_quest_EN.itemchoose = QTR_MessOrig.itemchoose1;
            QTR_quest_LG.itemchoose = QTR_Messages.itemchoose1;
            QTR_quest_EN.itemreceive = QTR_MessOrig.itemreceiv1;
            QTR_quest_LG.itemreceive = QTR_Messages.itemreceiv1;
         else                                                           -- zdarzenie z QuestLogu
            if (QTR_quest_LG.details ~= QuestInfoDescriptionText:GetText()) then
               if (not QTR_orig_table[str_ID].details) then        
                  QTR_quest_EN.details = QuestInfoDescriptionText:GetText();
                  QTR_orig_table[str_ID].details = QTR_quest_EN.details;
               else
                  QTR_quest_EN.details = QTR_orig_table[str_ID].details;
               end
            end
            if (QTR_quest_LG.objectives ~= QuestInfoObjectivesText:GetText()) then
               if (not QTR_orig_table[str_ID].objectives) then        
                  QTR_quest_EN.objectives = QuestInfoObjectivesText:GetText();
                  QTR_orig_table[str_ID].objectives = QTR_quest_EN.objectives;
               else
                  QTR_quest_EN.objectives = QTR_orig_table[str_ID].objectives;
               end
            end
            if (QTR_orig_table[str_ID].details==nil) then
               QTR_orig_table[str_ID].details = QuestInfoDescriptionText:GetText();
            end
            if (QTR_orig_table[str_ID].objectives==nil) then
               QTR_orig_table[str_ID].objectives = QuestInfoObjectivesText:GetText();
            end
         end   
         if (zdarzenie=="QUEST_PROGRESS") then
            if (not QTR_orig_table[str_ID].objectives) then        
               QTR_quest_EN.progress = GetProgressText();
               QTR_orig_table[str_ID].progress = QTR_quest_EN.progress;
            else
               QTR_quest_EN.progress = QTR_orig_table[str_ID].progress;
            end
            QTR_quest_LG.progress = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Progress"]);
            if (QTR_quest_LG.progress=="") then
               QTR_quest_LG.progress = "("..QTR_Messages.missing..")";
            end
         end
         if (zdarzenie=="QUEST_COMPLETE") then
            if (not QTR_orig_table[str_ID].objectives) then        
               QTR_quest_EN.completion = GetRewardText();
               QTR_orig_table[str_ID].completion = QTR_quest_EN.completion;
            else
               QTR_quest_EN.completion = QTR_orig_table[str_ID].completion;
            end
            QTR_quest_LG.completion = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Completion"]);
            QTR_quest_EN.itemchoose = QTR_MessOrig.itemchoose2;
            QTR_quest_LG.itemchoose = QTR_Messages.itemchoose2;
            QTR_quest_EN.itemreceive = QTR_MessOrig.itemreceiv2;
            QTR_quest_LG.itemreceive = QTR_Messages.itemreceiv2;
            if (QTR_quest_LG.completion=="") then
               QTR_quest_LG.completion = "("..QTR_Messages.missing..")";
            end
         end         
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_Translate_On(1);
      else	      -- nie ma przetłumaczonego takiego questu
         QTR_ToggleButton0:Disable();
         QTR_ToggleButton1:Disable();
         QTR_ToggleButton2:Disable();
         QTR_ToggleButton0:SetText("Quest ID="..str_ID);
         QTR_ToggleButton1:SetText("Quest ID="..str_ID);
         QTR_ToggleButton2:SetText("Quest ID="..str_ID);
         QTR_Translate_On(0);
      end -- jest przetłumaczony quest w bazie
   else	-- tłumaczenia wyłączone
      QTR_ToggleButton0:Disable();
      QTR_ToggleButton1:Disable();
      QTR_ToggleButton2:Disable();
      if ( QTR_QuestData[str_ID] ) then	-- ale jest tłumaczenie w bazie
         QTR_ToggleButton1:SetText("Quest ID="..str_ID.." ("..QTR_locale..")");
         QTR_ToggleButton2:SetText("Quest ID="..str_ID.." ("..QTR_locale..")");
      else
         QTR_ToggleButton1:SetText("Quest ID="..str_ID);
         QTR_ToggleButton2:SetText("Quest ID="..str_ID);
      end
   end	-- tłumaczenia są włączone
end


-- wyświetla tłumaczenie
function QTR_Translate_On(typ)
   if (QTR_PS["transtitle"]=="1") then    -- wyświetl przetłumaczony tytuł
      QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
      QuestProgressTitleText:SetFont(QTR_Font1, 18);
   end
   QuestInfoObjectivesHeader:SetFont(QTR_Font1, 18);
   QuestInfoObjectivesHeader:SetText(QTR_Messages.objectives);
   QuestInfoRewardsFrame.Header:SetFont(QTR_Font1, 18);
   QuestInfoRewardsFrame.Header:SetText(QTR_Messages.rewards);
   QuestInfoDescriptionHeader:SetFont(QTR_Font1, 18);
   QuestInfoDescriptionHeader:SetText(QTR_Messages.details);
   QuestProgressRequiredItemsText:SetFont(QTR_Font1, 18);
   QuestProgressRequiredItemsText:SetText(QTR_Messages.reqitems);
   QuestInfoDescriptionText:SetFont(QTR_Font2, 13);
   QuestInfoObjectivesText:SetFont(QTR_Font2, 13);
   QuestProgressText:SetFont(QTR_Font2, 13);
   QuestInfoRewardText:SetFont(QTR_Font2, 13);
   QuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 13);
   QuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 13);
   QuestInfoSpellObjectiveLearnLabel:SetFont(QTR_Font2, 13);
   QuestInfoSpellObjectiveLearnLabel:SetText(QTR_Messages.learnspell);
   QuestInfoXPFrame.ReceiveText:SetFont(QTR_Font2, 13);
   QuestInfoXPFrame.ReceiveText:SetText(QTR_Messages.experience);
--   MapQuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 11);
--   MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 11);
--   MapQuestInfoRewardsFrame.ItemChooseText:SetText(QTR_Messages.itemchoose1);
--   MapQuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_Messages.itemreceiv1);
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_Messages.itemchoose1);
      QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_Messages.itemreceiv1);
      numer_ID = QTR_quest_LG.id;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć przetłumaczoną wersję napisów
         if (QTR_PS["transtitle"]=="1") then
            QuestInfoTitleHeader:SetText(QTR_quest_LG.title);
            QuestProgressTitleText:SetText(QTR_quest_LG.title);
         end
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_LG.id.." ("..QTR_lang..")");
         QuestInfoDescriptionText:SetText(QTR_quest_LG.details);
         QuestInfoObjectivesText:SetText(QTR_quest_LG.objectives);
         QuestProgressText:SetText(QTR_quest_LG.progress);
         QuestInfoRewardText:SetText(QTR_quest_LG.completion);
--         QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_quest_LG.itemchoose);
--         QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_quest_LG.itemreceive);
      end
   else
      if (curr_trans == "1") then
         QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_Messages.itemchoose1);
         QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_Messages.itemreceiv1);
      end
   end
end


-- wyświetla oryginalny tekst
function QTR_Translate_Off(typ)
   QuestInfoTitleHeader:SetFont(Original_Font1, 18);
   QuestProgressTitleText:SetFont(Original_Font1, 18);
   QuestInfoObjectivesHeader:SetFont(Original_Font1, 18);
   QuestInfoObjectivesHeader:SetText(QTR_MessOrig.objectives);
   QuestInfoRewardsFrame.Header:SetFont(Original_Font1, 18);
   QuestInfoRewardsFrame.Header:SetText(QTR_MessOrig.rewards);
   QuestInfoDescriptionHeader:SetFont(Original_Font1, 18);
   QuestInfoDescriptionHeader:SetText(QTR_MessOrig.details);
   QuestProgressRequiredItemsText:SetFont(Original_Font1, 18);
   QuestProgressRequiredItemsText:SetText(QTR_MessOrig.reqitems);
   QuestInfoDescriptionText:SetFont(Original_Font2, 13);
   QuestInfoObjectivesText:SetFont(Original_Font2, 13);
   QuestProgressText:SetFont(Original_Font2, 13);
   QuestInfoRewardText:SetFont(Original_Font2, 13);
   QuestInfoRewardsFrame.ItemChooseText:SetFont(Original_Font2, 13);
   QuestInfoRewardsFrame.ItemReceiveText:SetFont(Original_Font2, 13);
--   MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(Original_Font2, 11);
--   MapQuestInfoRewardsFrame.ItemChooseText:SetFont(Original_Font2, 11);
   QuestInfoSpellObjectiveLearnLabel:SetFont(Original_Font2, 13);
   QuestInfoSpellObjectiveLearnLabel:SetText(QTR_MessOrig.learnspell);
   QuestInfoXPFrame.ReceiveText:SetFont(Original_Font2, 13);
   QuestInfoXPFrame.ReceiveText:SetText(QTR_MessOrig.experience);
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_MessOrig.itemchoose1);
      QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
--      MapQuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_MessOrig.itemreceiv1);
--      MapQuestInfoRewardsFrame.ItemChooseText:SetText(QTR_MessOrig.itemreceiv1);
      numer_ID = QTR_quest_EN.id;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć oryginalną wersję napisów
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_EN.id.." ("..QTR_locale..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_EN.id.." ("..QTR_locale..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_EN.id.." ("..QTR_locale..")");
         QuestInfoTitleHeader:SetText(QTR_orig_table[str_ID].title);
         QuestProgressTitleText:SetText(QTR_orig_table[str_ID].title);
         QuestInfoDescriptionText:SetText(QTR_orig_table[str_ID].details);
         QuestInfoObjectivesText:SetText(QTR_orig_table[str_ID].objectives);
         QuestProgressText:SetText(QTR_orig_table[str_ID].progress);
         QuestInfoRewardText:SetText(QTR_orig_table[str_ID].completion);
--         QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_quest_EN.itemchoose);
--         QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_quest_EN.itemreceive);
      end
   end
end


function QTR_delayed3()
end


function QTR_delayed4()
   QTR_QuestPrepare('');
end;      


function QTR_PrepareDelay(czas)     -- wywoływane po kliknięciu na nazwę questu z listy NPC
   if (czas==1) then
      if (not QTR_wait(1,QTR_PrepareReload)) then
      ---
      end
   end
   if (czas==3) then
      if (not QTR_wait(3,QTR_PrepareReload)) then
      ---
      end
   end
end;      


function QTR_PrepareReload()
   QTR_QuestPrepare('');
end;      


-- podmieniaj specjane znaki w tekście
function QTR_ExpandUnitInfo(msg)
   msg = string.gsub(msg, "NEW_LINE", "\n");
   msg = string.gsub(msg, "YOUR_NAME", QTR_name);

   msg = string.gsub(msg, "YOUR_CLASS", player_class);        
   msg = string.gsub(msg, "YOUR_RACE", player_race);          

-- jeszcze obsłużyć YOUR_GENDER(x;y)
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "YOUR_GENDER");    -- gdy nie znalazł, jest: nil
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(msg, nr_1, nr_1) ~= "(") do
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(msg, "YOUR_GENDER");
   end
   
   return msg;
end
