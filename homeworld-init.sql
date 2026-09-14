-- =========================================================
-- homeworld · Migration 0001 · Phase 1 base schema · v2.1.1
-- =========================================================

CREATE TABLE players (
  id            TEXT PRIMARY KEY,
  display_name  TEXT NOT NULL,
  created_at    INTEGER NOT NULL,
  last_seen_at  INTEGER NOT NULL
);

CREATE TABLE player_state (
  player_id     TEXT PRIMARY KEY REFERENCES players(id),
  stamina       INTEGER NOT NULL DEFAULT 100 CHECK (stamina >= 0),
  max_stamina   INTEGER NOT NULL DEFAULT 100 CHECK (max_stamina > 0),
  location      TEXT    NOT NULL DEFAULT 'home',
  updated_at    INTEGER NOT NULL,
  CHECK (stamina <= max_stamina)
);

CREATE TABLE wallets (
  player_id     TEXT PRIMARY KEY REFERENCES players(id),
  gold          INTEGER NOT NULL DEFAULT 0 CHECK (gold >= 0),
  updated_at    INTEGER NOT NULL
);

CREATE TABLE wallet_transactions (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  player_id         TEXT NOT NULL REFERENCES players(id),
  actor_id          TEXT,
  delta             INTEGER NOT NULL,
  balance_after     INTEGER NOT NULL CHECK (balance_after >= 0),
  reason            TEXT NOT NULL,
  counterparty      TEXT,
  note              TEXT,
  game_year         INTEGER NOT NULL,
  season            TEXT    NOT NULL,
  game_day          INTEGER NOT NULL,
  game_time         INTEGER NOT NULL,
  world_day_index   INTEGER NOT NULL,
  created_at        INTEGER NOT NULL
);
CREATE INDEX idx_wallet_tx_player ON wallet_transactions(player_id, created_at DESC);
CREATE INDEX idx_wallet_tx_wdi    ON wallet_transactions(world_day_index);

CREATE TABLE item_definitions (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  type         TEXT NOT NULL,
  buy_price    INTEGER NOT NULL DEFAULT 0 CHECK (buy_price >= 0),
  sell_price   INTEGER NOT NULL DEFAULT 0 CHECK (sell_price >= 0),
  stackable    INTEGER NOT NULL DEFAULT 1 CHECK (stackable IN (0,1)),
  description  TEXT
);

CREATE TABLE inventory_stacks (
  player_id   TEXT NOT NULL REFERENCES players(id),
  item_id     TEXT NOT NULL REFERENCES item_definitions(id),
  quantity    INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  updated_at  INTEGER NOT NULL,
  PRIMARY KEY (player_id, item_id)
);

CREATE TABLE fish_species (
  id             TEXT PRIMARY KEY,
  name           TEXT NOT NULL,
  rarity         INTEGER NOT NULL CHECK (rarity BETWEEN 1 AND 5),
  min_weight_g   INTEGER NOT NULL CHECK (min_weight_g > 0),
  max_weight_g   INTEGER NOT NULL CHECK (max_weight_g > min_weight_g),
  weight_skew    REAL    NOT NULL DEFAULT 2.5 CHECK (weight_skew > 1.0),
  price_per_kg   INTEGER NOT NULL CHECK (price_per_kg >= 0),
  spawn_weight   INTEGER NOT NULL CHECK (spawn_weight > 0),
  seasons        TEXT NOT NULL,
  times          TEXT NOT NULL,
  weathers       TEXT NOT NULL,
  locations      TEXT NOT NULL,
  description    TEXT
);

CREATE TABLE fish_bait_modifiers (
  species_id  TEXT NOT NULL REFERENCES fish_species(id),
  bait_id     TEXT NOT NULL REFERENCES item_definitions(id),
  multiplier  REAL NOT NULL CHECK (multiplier >= 0),
  PRIMARY KEY (species_id, bait_id)
);

CREATE TABLE fish_catches (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  player_id        TEXT NOT NULL REFERENCES players(id),
  actor_id         TEXT NOT NULL,
  species_id       TEXT NOT NULL REFERENCES fish_species(id),
  weight_g         INTEGER NOT NULL CHECK (weight_g > 0),
  grade            TEXT    NOT NULL CHECK (grade IN ('C','B','A','S','SS','Trophy')),
  price            INTEGER NOT NULL CHECK (price >= 0),
  is_new_species   INTEGER NOT NULL DEFAULT 0 CHECK (is_new_species IN (0,1)),
  is_new_record    INTEGER NOT NULL DEFAULT 0 CHECK (is_new_record IN (0,1)),
  status           TEXT NOT NULL DEFAULT 'inventory' CHECK (status IN ('inventory','sold')),
  is_favorite      INTEGER NOT NULL DEFAULT 0 CHECK (is_favorite IN (0,1)),
  is_locked        INTEGER NOT NULL DEFAULT 0 CHECK (is_locked IN (0,1)),
  lock_reason      TEXT,
  sold_at          INTEGER,
  location         TEXT    NOT NULL,
  bait_id          TEXT    NOT NULL REFERENCES item_definitions(id),
  game_year        INTEGER NOT NULL,
  season           TEXT    NOT NULL,
  weather          TEXT    NOT NULL,
  game_day         INTEGER NOT NULL,
  game_time        INTEGER NOT NULL,
  world_day_index  INTEGER NOT NULL,
  request_id       TEXT    NOT NULL,
  caught_at        INTEGER NOT NULL
);
CREATE INDEX idx_fish_player_status   ON fish_catches(player_id, status);
CREATE INDEX idx_fish_player_species  ON fish_catches(player_id, species_id);
CREATE INDEX idx_fish_request         ON fish_catches(request_id);
CREATE INDEX idx_fish_wdi             ON fish_catches(world_day_index);

CREATE TABLE codex_fish (
  player_id        TEXT NOT NULL REFERENCES players(id),
  species_id       TEXT NOT NULL REFERENCES fish_species(id),
  first_caught_at  INTEGER NOT NULL,
  catch_count      INTEGER NOT NULL DEFAULT 1 CHECK (catch_count >= 1),
  max_weight_g     INTEGER NOT NULL CHECK (max_weight_g > 0),
  max_grade        TEXT    NOT NULL CHECK (max_grade IN ('C','B','A','S','SS','Trophy')),
  PRIMARY KEY (player_id, species_id)
);

CREATE TABLE world_state (
  id                           INTEGER PRIMARY KEY CHECK (id = 1),
  world_day_index              INTEGER NOT NULL DEFAULT 1 CHECK (world_day_index >= 1),
  game_day                     INTEGER NOT NULL DEFAULT 1 CHECK (game_day BETWEEN 1 AND 28),
  season                       TEXT    NOT NULL DEFAULT 'spring'
                               CHECK (season IN ('spring','summer','autumn','winter')),
  year                         INTEGER NOT NULL DEFAULT 1 CHECK (year >= 1),
  game_minute_of_day           INTEGER NOT NULL DEFAULT 300
                               CHECK (game_minute_of_day BETWEEN 0 AND 1439),
  weather                      TEXT    NOT NULL DEFAULT 'sunny',
  weather_locked_for_world_day INTEGER NOT NULL DEFAULT 1 CHECK (weather_locked_for_world_day >= 1),
  updated_at                   INTEGER NOT NULL
);

CREATE TABLE achievements (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  description  TEXT NOT NULL,
  hidden       INTEGER NOT NULL DEFAULT 0 CHECK (hidden IN (0,1))
);

CREATE TABLE player_achievements (
  player_id        TEXT NOT NULL REFERENCES players(id),
  achievement_id   TEXT NOT NULL REFERENCES achievements(id),
  unlocked_at      INTEGER NOT NULL,
  world_day_index  INTEGER NOT NULL CHECK (world_day_index >= 1),
  game_time        INTEGER NOT NULL CHECK (game_time BETWEEN 0 AND 1439),
  PRIMARY KEY (player_id, achievement_id)
);

CREATE TABLE action_logs (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  player_id        TEXT NOT NULL REFERENCES players(id),
  actor_id         TEXT NOT NULL,
  action           TEXT NOT NULL,
  location         TEXT,
  summary          TEXT NOT NULL,
  details          TEXT,
  game_year        INTEGER NOT NULL,
  season           TEXT    NOT NULL,
  game_day         INTEGER NOT NULL,
  game_time        INTEGER NOT NULL,
  world_day_index  INTEGER NOT NULL,
  created_at       INTEGER NOT NULL
);
CREATE INDEX idx_logs_player_time ON action_logs(player_id, created_at DESC);
CREATE INDEX idx_logs_wdi         ON action_logs(world_day_index);

CREATE TABLE action_requests (
  request_id   TEXT PRIMARY KEY,
  actor_id     TEXT NOT NULL,
  player_id    TEXT NOT NULL REFERENCES players(id),
  action       TEXT NOT NULL,
  result_json  TEXT NOT NULL,
  created_at   INTEGER NOT NULL
);
-- =========================================================
-- homeworld · Migration 0002 · global state revision gate
-- 目的：用 UNIQUE(state_revision_before) 把
--       所有真实状态修改动作序列化，杜绝 world_state 的 lost update。
-- =========================================================

ALTER TABLE world_state
  ADD COLUMN revision INTEGER NOT NULL DEFAULT 0;

ALTER TABLE action_requests
  ADD COLUMN state_revision_before INTEGER;

CREATE UNIQUE INDEX idx_action_requests_state_revision
  ON action_requests(state_revision_before);
INSERT INTO item_definitions (id, name, type, buy_price, sell_price, stackable, description) VALUES
  ('worm',  '蚯蚓', 'bait', 3, 1, 1, '从河边泥土里挖出来的，几乎所有鱼都爱吃。'),
  ('dough', '面团', 'bait', 5, 1, 1, '用面粉和水揉成的小团，对草食性的鱼格外有吸引力。');
INSERT INTO fish_species
  (id, name, rarity, min_weight_g, max_weight_g, weight_skew, price_per_kg, spawn_weight,
   seasons, times, weathers, locations, description) VALUES
  ('crucian_carp', '鲫鱼', 1, 80, 1500, 2.5, 300, 100,
   '["spring","summer","autumn","winter"]', '["dawn","day","dusk","night"]',
   '["sunny","cloudy","light_rain","rain","thunder","snow","fog"]', '["river"]',
   '河边最常见的小鱼。全年、全天、什么天气都能遇到。'),
  ('common_carp', '鲤鱼', 2, 300, 8000, 2.6, 400, 60,
   '["spring","summer"]', '["day"]', '["sunny","cloudy"]', '["river"]',
   '春夏季白天出没，个体越大越少见，是重量纪录的常客。'),
  ('cherry_salmon', '樱鳟', 3, 400, 2500, 2.4, 800, 20,
   '["spring"]', '["dawn"]', '["sunny"]', '["river"]',
   '只在春天清晨的晴日靠岸。春天错过，就要再等一年。'),
  ('sweetfish', '香鱼', 2, 60, 400, 2.5, 700, 50,
   '["summer"]', '["day"]', '["sunny","cloudy","light_rain"]', '["river"]',
   '夏季白天的主力鱼，体型不大，但市面上价格不低。'),
  ('spined_loach', '花鳅', 2, 20, 150, 2.6, 500, 40,
   '["spring","summer","autumn","winter"]', '["night"]',
   '["sunny","cloudy","light_rain","rain","snow","fog"]', '["river"]',
   '夜晚才浮上浅滩的小鱼，白天几乎见不到。'),
  ('catfish', '鲶鱼', 3, 800, 6000, 2.7, 600, 25,
   '["summer"]', '["night"]', '["cloudy","light_rain","rain"]', '["river"]',
   '夏季阴雨夜晚才活动的大鱼。又黑又沉，力气不小。'),
  ('rainbow_trout', '虹鳟', 2, 300, 3500, 2.5, 650, 45,
   '["spring","autumn"]', '["dusk"]',
   '["sunny","cloudy","light_rain","rain","fog"]', '["river"]',
   '春秋两季的黄昏靠岸觅食，光影下鳞片像一道拱桥。'),
  ('salmon', '鲑鱼', 3, 1500, 12000, 2.6, 900, 20,
   '["autumn"]', '["day"]', '["sunny","cloudy","light_rain","rain","fog"]', '["river"]',
   '秋季洄游。体型大，价格高，是秋季收入的主要来源。'),
  ('pond_loach', '泥鳅', 2, 15, 120, 2.5, 450, 35,
   '["spring","summer","autumn","winter"]', '["night"]',
   '["light_rain","rain","thunder"]', '["river"]',
   '雨天夜里在泥底乱窜。小、滑、不好抓，但卖得不便宜。'),
  ('icefish', '冰鱼', 3, 100, 800, 2.4, 1000, 30,
   '["winter"]', '["dawn","day","dusk","night"]', '["snow"]', '["river"]',
   '雪天下的冬季限定鱼，整条几乎透明，握在手里冰凉。'),
  ('thunderfish', '大雷鱼', 4, 2000, 15000, 2.8, 1500, 8,
   '["summer"]', '["night"]', '["thunder"]', '["river"]',
   '夏季雷雨夜里才会浮出水面的大鱼，据说鳞片会导电。'),
  ('arowana', '金龙鱼', 5, 500, 5000, 2.9, 3000, 3,
   '["spring","summer","autumn","winter"]', '["dawn"]',
   '["sunny","cloudy","light_rain","rain","thunder","snow","fog"]', '["river"]',
   '全年清晨都可能出现，但概率极低。钓到它的人都说像做了个梦。');
INSERT INTO fish_bait_modifiers (species_id, bait_id, multiplier) VALUES
  ('crucian_carp', 'worm', 1.0), ('crucian_carp', 'dough', 1.3),
  ('common_carp', 'worm', 1.2), ('common_carp', 'dough', 1.0),
  ('cherry_salmon', 'worm', 1.0), ('cherry_salmon', 'dough', 0.8),
  ('sweetfish', 'worm', 0.7), ('sweetfish', 'dough', 1.4),
  ('spined_loach', 'worm', 1.5), ('spined_loach', 'dough', 0.5),
  ('catfish', 'worm', 1.5), ('catfish', 'dough', 0.3),
  ('rainbow_trout', 'worm', 1.0), ('rainbow_trout', 'dough', 1.1),
  ('salmon', 'worm', 0.8), ('salmon', 'dough', 1.3),
  ('pond_loach', 'worm', 1.4), ('pond_loach', 'dough', 0.6),
  ('icefish', 'worm', 1.0), ('icefish', 'dough', 1.0),
  ('thunderfish', 'worm', 1.2), ('thunderfish', 'dough', 0.8),
  ('arowana', 'worm', 0.9), ('arowana', 'dough', 1.1);
INSERT INTO achievements (id, name, description, hidden) VALUES
  ('first_action', '终于让我玩上了', '在经历 YouTube、CAPTCHA、Tiny Fishing、2048 和扫雷之后，你终于按动了一个按钮。', 0),
  ('first_cast', '第一次抛竿', '把鱼钩扔进水里。', 0),
  ('first_fish', '第一条鱼', '恭喜，这个世界开始和你对话了。', 0),
  ('first_ss', '罕见的个体', '钓到一条个体评级 SS 的鱼。', 0),
  ('first_trophy', '传说', '钓到一条个体评级 Trophy 的鱼。这不是运气，这是命运。', 0),
  ('codex_6', '半本鱼谱', '鱼类图鉴收录 6 种。', 0),
  ('codex_12', '第一册鱼谱', '把目前能够记录的十二种鱼都收入了图鉴。', 0),
  ('rich_1000', '小康', '钱包首次达到 1000G。', 0),
  ('rich_10000', '万元户', '钱包首次达到 10000G。', 0);
INSERT INTO players (id, display_name, created_at, last_seen_at) VALUES
  ('home_gpt', '家机', CAST(strftime('%s','now') AS INTEGER) * 1000, CAST(strftime('%s','now') AS INTEGER) * 1000),
  ('mouse', '鼠', CAST(strftime('%s','now') AS INTEGER) * 1000, CAST(strftime('%s','now') AS INTEGER) * 1000);

INSERT INTO player_state (player_id, stamina, max_stamina, location, updated_at) VALUES
  ('home_gpt', 100, 100, 'home', CAST(strftime('%s','now') AS INTEGER) * 1000),
  ('mouse', 100, 100, 'home', CAST(strftime('%s','now') AS INTEGER) * 1000);

INSERT INTO wallets (player_id, gold, updated_at) VALUES
  ('home_gpt', 200, CAST(strftime('%s','now') AS INTEGER) * 1000),
  ('mouse', 1000, CAST(strftime('%s','now') AS INTEGER) * 1000);

INSERT INTO inventory_stacks (player_id, item_id, quantity, updated_at) VALUES
  ('home_gpt', 'worm', 10, CAST(strftime('%s','now') AS INTEGER) * 1000),
  ('home_gpt', 'dough', 5, CAST(strftime('%s','now') AS INTEGER) * 1000);

INSERT INTO world_state
  (id, world_day_index, game_day, season, year, game_minute_of_day,
   weather, weather_locked_for_world_day, updated_at)
VALUES
  (1, 1, 1, 'spring', 1, 300, 'sunny', 1, CAST(strftime('%s','now') AS INTEGER) * 1000);
