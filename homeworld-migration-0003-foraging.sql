-- =========================================================
-- homeworld · Migration 0003 · Foraging
-- =========================================================

CREATE TABLE IF NOT EXISTS forage_definitions (
  item_id       TEXT PRIMARY KEY REFERENCES item_definitions(id),
  spawn_weight  INTEGER NOT NULL CHECK (spawn_weight > 0),
  min_quantity  INTEGER NOT NULL CHECK (min_quantity > 0),
  max_quantity  INTEGER NOT NULL CHECK (max_quantity >= min_quantity),
  seasons       TEXT NOT NULL,
  times         TEXT NOT NULL,
  weathers      TEXT NOT NULL,
  locations     TEXT NOT NULL,
  description   TEXT
);

INSERT OR IGNORE INTO item_definitions
  (id, name, type, buy_price, sell_price, stackable, description) VALUES
  ('branch',       '树枝',   'forage', 0,  2, 1, '森林里随处可见的枯枝。价值不高，但以后可能用于 crafting。'),
  ('wild_berry',   '野莓',   'forage', 0,  8, 1, '酸甜的小浆果。'),
  ('mushroom',     '蘑菇',   'forage', 0, 12, 1, '潮湿林地里长的蘑菇。'),
  ('wild_greens',  '野菜',   'forage', 0, 10, 1, '嫩绿的野生蔬菜。'),
  ('wildflower',   '野花',   'forage', 0,  9, 1, '林间开的小花。'),
  ('chestnut',     '栗子',   'forage', 0, 15, 1, '秋天落在地上的栗子。'),
  ('pinecone',     '松果',   'forage', 0,  6, 1, '松树下捡到的松果。'),
  ('winter_berry', '冬莓',   'forage', 0, 18, 1, '雪地里罕见的红色浆果。');

INSERT OR IGNORE INTO forage_definitions
  (item_id, spawn_weight, min_quantity, max_quantity,
   seasons, times, weathers, locations, description) VALUES
  ('branch', 100, 1, 3,
   '["spring","summer","autumn","winter"]',
   '["dawn","day","dusk","night"]',
   '["sunny","cloudy","light_rain","rain","thunder","snow","fog"]',
   '["forest"]',
   '森林里随处可见的枯枝。价值不高，但以后可能用于 crafting。'),
  ('wild_berry', 55, 1, 3,
   '["spring","summer","autumn"]',
   '["dawn","day","dusk"]',
   '["sunny","cloudy","light_rain"]',
   '["forest"]',
   '酸甜的小浆果。'),
  ('mushroom', 35, 1, 2,
   '["spring","autumn"]',
   '["dawn","day"]',
   '["cloudy","light_rain","rain","fog"]',
   '["forest"]',
   '潮湿林地里长的蘑菇。'),
  ('wild_greens', 45, 1, 2,
   '["spring","summer"]',
   '["dawn","day","dusk"]',
   '["sunny","cloudy","light_rain","rain"]',
   '["forest"]',
   '嫩绿的野生蔬菜。'),
  ('wildflower', 30, 1, 2,
   '["spring","summer"]',
   '["day","dusk"]',
   '["sunny","cloudy"]',
   '["forest"]',
   '林间开的小花。'),
  ('chestnut', 25, 1, 3,
   '["autumn"]',
   '["day","dusk"]',
   '["sunny","cloudy"]',
   '["forest"]',
   '秋天落在地上的栗子。'),
  ('pinecone', 45, 1, 2,
   '["autumn","winter"]',
   '["dawn","day","dusk"]',
   '["sunny","cloudy","snow"]',
   '["forest"]',
   '松树下捡到的松果。'),
  ('winter_berry', 20, 1, 2,
   '["winter"]',
   '["dawn","day"]',
   '["sunny","cloudy","snow","fog"]',
   '["forest"]',
   '雪地里罕见的红色浆果。');
