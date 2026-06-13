-- ══════════════════════════════════════════════════════════════════
-- WK Bingo 2026 — Supabase Setup SQL
-- Draai dit in jouw Supabase SQL editor als je een ander project wilt gebruiken
-- (bijv. hetzelfde project als Dart Bingo: jpxvpnvxljhvlfrcszhy)
-- ══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS wk_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  label TEXT NOT NULL,
  description TEXT DEFAULT '',
  slok INTEGER NOT NULL DEFAULT 1,
  slok_type TEXT NOT NULL DEFAULT 'slok',
  category TEXT NOT NULL DEFAULT 'veld',
  emoji TEXT DEFAULT '⚽',
  vibrate BOOLEAN DEFAULT false,
  is_rare BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wk_sessions (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL DEFAULT 'WK Sessie',
  match_name TEXT DEFAULT '',
  match_score TEXT DEFAULT '',
  categories TEXT[] DEFAULT ARRAY['veld','var','trainer','supporters'],
  grid_size INTEGER DEFAULT 4,
  require_login BOOLEAN DEFAULT false,
  password TEXT DEFAULT '',
  status TEXT DEFAULT 'lobby',
  host_color TEXT,
  event_pool JSONB DEFAULT '[]'::jsonb,
  water_alarm INTEGER DEFAULT 15,
  mooiste_goal_nr INTEGER DEFAULT 3,
  host_alert JSONB DEFAULT NULL,
  goal_count INTEGER DEFAULT 0,
  predictions_config JSONB DEFAULT '[]'::jsonb,
  predictions_correct JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wk_players (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id TEXT REFERENCES wk_sessions(id) ON DELETE CASCADE,
  user_id UUID,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  avatar TEXT DEFAULT '⚽',
  card JSONB DEFAULT '[]'::jsonb,
  counts JSONB DEFAULT '[]'::jsonb,
  bingo_lines JSONB DEFAULT '[]'::jsonb,
  total_slok INTEGER DEFAULT 0,
  achievements JSONB DEFAULT '[]'::jsonb,
  version INTEGER DEFAULT 0,
  is_host BOOLEAN DEFAULT false,
  is_kicked BOOLEAN DEFAULT false,
  extra_vakjes JSONB DEFAULT '[]'::jsonb,
  predictions JSONB DEFAULT '{}'::jsonb,
  card_approved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE wk_events  ENABLE ROW LEVEL SECURITY;
ALTER TABLE wk_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wk_players  ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wk_events_all"   ON wk_events   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "wk_sessions_all" ON wk_sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "wk_players_all"  ON wk_players  FOR ALL USING (true) WITH CHECK (true);

ALTER PUBLICATION supabase_realtime ADD TABLE wk_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE wk_players;

-- Seed vakjes (zelfde als in het MCP-project)
INSERT INTO wk_events (label,description,slok,slok_type,category,emoji,vibrate,is_rare,sort_order) VALUES
('Doelpunt! ⚽','Er wordt gescoord',0,'adje_iedereen','veld','⚽',false,true,1),
('Eigen doelpunt','Speler scoort in eigen doel',0,'dubbel_adje','veld','😱',true,true,2),
('Penalty toegekend','',3,'slok','veld','🟢',false,false,3),
('Penalty gemist','',0,'adje_iedereen','veld','😤',true,true,4),
('Penalty gestopt','Keeper pakt de strafschop',3,'slok','veld','🧤',false,false,5),
('Penalty gescoord','',2,'slok','veld','✅',false,false,6),
('Gele kaart','',2,'slok','veld','🟨',false,false,7),
('Rode kaart','Speler van het veld',0,'adje','veld','🟥',true,true,8),
('2e gele = rood','',0,'adje','veld','🟨🟥',true,true,9),
('Vrije trap gescoord','',3,'slok','veld','🎯',false,false,10),
('Vrije trap op de muur','',1,'slok','veld','🧱',false,false,11),
('Schot op de paal','',3,'slok','veld','🪵',false,false,12),
('Schot op de lat','',3,'slok','veld','🪵',false,false,13),
('Paal én lat zelfde fase','Ultra zeldzaam',0,'adje_iedereen','veld','😱',true,true,14),
('Keeper redt met voet','',2,'slok','veld','🦶',false,false,15),
('Speler verliest schoen','',2,'slok','veld','👟',true,false,16),
('Schwalbe (theatrale val)','Speler overdrijft de val',2,'slok','veld','🎭',true,false,17),
('Lange inworp richting 16','Directe inworp het strafschopgebied in',1,'slok','veld','↗️',false,false,18),
('Tackle van achteren','',2,'slok','veld','⚡',false,false,19),
('Spits mist bijna open doel','Van dichtbij keihard naast',3,'slok','veld','🙈',false,false,20),
('Vrije trap nergens op','Schot ver over of naast',1,'slok','veld','😅',false,false,21),
('Bal hoog over het stadion','Schot radicaal over het doel',3,'slok','veld','🚀',false,false,22),
('Uitglijder bij schot/pass','Speler glijdt uit',2,'slok','veld','🛷',false,false,23),
('Schot geblokt met achterwerk','Of rug',2,'slok','veld','🍑',false,false,24),
('Keeper vangt klem','Na hard schot',2,'slok','veld','🧤',false,false,25),
('Verdediger kopt terug op keeper','Terugkopbal eigen keeper',2,'slok','veld','🔙',false,false,26),
('Overtreding op de keeper','',2,'slok','veld','🚫',false,false,27),
('Panna!','Tegenstander gepoort',3,'slok','veld','🫢',false,false,28),
('Kopbal gescoord','Doelpunt met het hoofd',2,'slok','veld','🤕',false,false,29),
('Goal van buiten de 16','Afstandsschot raak',3,'slok','veld','💥',false,false,30),
('Mooiste goal! 🌟','De vooraf gekozen goal valt',0,'adje','veld','🌟',true,true,31),
('Keeper schiet bij tegenstander','Slechte afgooi',2,'slok','snel','🎁',false,false,1),
('Linksback speelt met rechts','Gebruikt zijn slechtste voet',1,'slok','snel','🦶',false,false,2),
('De spits kopt de bal','Ongeacht richting of resultaat',1,'slok','snel','🤜',false,false,3),
('Linksbuiten speelt man voorbij','Succesvolle dribble op de flank',2,'slok','snel','💨',false,false,4),
('VAR-check gestart','',2,'slok','var','📺',false,false,1),
('Scheids naar de monitor','Loopt naar zijlijn voor review',3,'slok','var','🖥️',false,false,2),
('VAR haalt penalty weg','',0,'adje_iedereen','var','❌',true,true,3),
('Millimeter buitenspellijn','Extreem dunne lijn in beeld',2,'slok','var','📏',false,false,4),
('Belachelijk dunne offside-lijn','Echt ridicuul',3,'slok','var','🔬',false,false,5),
('Spelers omringen de scheids','',1,'slok','var','🔄',false,false,6),
('>5 min blessuretijd','Meer dan 5 minuten extra',2,'slok','var','⏱️',false,false,7),
('Trainer woedend langs lijn','',2,'slok','trainer','😡',false,false,1),
('Wissel doorgevoerd','Spelerswissel',1,'slok','trainer','🔄',false,false,2),
('Wisselspeler kijkt boos','Net gewisseld en niet blij',2,'slok','trainer','😤',false,false,3),
('Keeperswisseling','Keeper wordt gewisseld',0,'adje','trainer','🧤',true,true,4),
('Fysiotherapeut rent op','',1,'slok','trainer','🏃',false,false,5),
('Krampen tijdens het spel','',1,'slok','trainer','🦵',false,false,6),
('Verdediger als aanvaller (laatste 10 min)','Noodgreep trainer',2,'slok','trainer','⬆️',false,false,7),
('Supporter huilend in beeld','',2,'slok','supporters','😭',false,false,1),
('Supporter belachelijk kostuum','',2,'slok','supporters','🎭',false,false,2),
('Supporter verkleed als non-voetbal','Wortel, pizza, astronaut',3,'slok','supporters','🥕',false,false,3),
('Groep met geschilderde gezichten','',1,'slok','supporters','🎨',false,false,4),
('Supporter viert te vroeg','Al juichen vóór het goal',3,'slok','supporters','🤦',false,false,5),
('Supporter gooit iets op veld','',2,'slok','supporters','⚠️',false,false,6),
('Vuvuzela/trommel in beeld','',1,'slok','supporters','📯',false,false,7),
('Spandoek met grappige tekst','',2,'slok','supporters','📋',false,false,8),
('Camera pakt slapende fan','',3,'slok','supporters','😴',false,false,9),
('Fan rent het veld op','',0,'adje_iedereen','supporters','🏃',true,true,10),
('Commentator cliché','→ jij deelt slokken uit',2,'uitdelen','commentator','🎤',false,false,1),
('Co-commentator oneens met scheids','',1,'slok','commentator','🗣️',false,false,2),
('Commentator noemt naam verkeerd','Verkeerde speler of land',3,'slok','commentator','😬',false,false,3),
('Reclame op verkeerd moment','Gemiste actie door reclame',2,'slok','commentator','📺',false,false,4),
('Commentator stil bij doelpunt','Te gefocust om te praten',2,'slok','commentator','🤫',false,false,5),
('Camera mist actie, toont tribune','',2,'slok','commentator','📷',false,false,6),
('Speler negeert ploeggenoten bij viering','',2,'slok','overig','😐',false,false,1),
('Speler huilt na doelpunt','',2,'slok','overig','😢',false,false,2)
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════════════════
-- MIGRATIE — draai dit als je een bestaand project bijwerkt
-- ══════════════════════════════════════════════════════════════════
ALTER TABLE wk_sessions
  ADD COLUMN IF NOT EXISTS predictions_config JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS predictions_correct JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS team_a TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS team_b TEXT DEFAULT '';

ALTER TABLE wk_players
  ADD COLUMN IF NOT EXISTS predictions JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS card_approved BOOLEAN DEFAULT false;
