// GTO opening, 3-bet and calling ranges for 6-max poker.
// Structure: position → scenario → Set<handCode>
// Hand codes: rank1+rank2+'s'/'o' for suited/offsuit, rank+rank for pairs.
// Positions: UTG, MP, CO, BTN, SB, BB
// Scenarios: open, 3bet, call

const Map<String, Map<String, Set<String>>> gtoRanges = {
  // ── UTG (~13% of hands) ───────────────────────────────────────────────────
  'UTG': {
    'open': {
      // Pairs 77+
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77',
      // Suited broadways
      'AKs', 'AQs', 'KQs',
      // Offsuit premiums
      'AKo',
    },
    '3bet': {
      // Re-raise range from UTG vs open: premiums only
      'AA', 'KK', 'QQ', 'AKs', 'AKo',
    },
    'call': {
      // Calling vs 3-bet from UTG: strong hands that don't want to 4-bet
      'JJ', 'TT', 'AQs', 'KQs',
    },
  },

  // ── MP (~20% of hands) ────────────────────────────────────────────────────
  'MP': {
    'open': {
      // Pairs 44+
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44',
      // Suited broadways
      'AKs', 'AQs', 'AJs', 'KQs',
      // Offsuit premiums
      'AKo', 'AQo', 'KQo',
    },
    '3bet': {
      'AA', 'KK', 'QQ', 'AKs', 'AQs', 'AKo',
    },
    'call': {
      'JJ', 'TT', '99', 'AJs', 'KQs', 'AQo',
    },
  },

  // ── CO (~30% of hands) ────────────────────────────────────────────────────
  'CO': {
    'open': {
      // Pairs 22+
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44',
      '33', '22',
      // Suited aces
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s',
      'A4s', 'A3s', 'A2s',
      // Suited kings and queens
      'KQs', 'KJs', 'QJs',
      // Suited connectors
      'JTs', 'T9s', '98s',
      // Offsuit broadways
      'AKo', 'AQo', 'AJo', 'KQo', 'KJo',
    },
    '3bet': {
      'AA', 'KK', 'QQ', 'JJ', 'AKs', 'AQs', 'AJs', 'A5s', 'A4s',
      'AKo', 'AQo',
    },
    'call': {
      'TT', '99', '88', 'ATs', 'KQs', 'KJs', 'QJs', 'JTs',
      'AJo', 'KJo',
    },
  },

  // ── BTN (~45% of hands) ───────────────────────────────────────────────────
  'BTN': {
    'open': {
      // All pairs
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44',
      '33', '22',
      // All suited aces
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s',
      'A4s', 'A3s', 'A2s',
      // Suited kings
      'KQs', 'KJs', 'KTs', 'K9s',
      // Suited queens
      'QJs', 'QTs',
      // Suited connectors / one-gappers
      'JTs', 'T9s', '98s', '87s', '76s', '65s',
      // Offsuit broadways
      'AKo', 'AQo', 'AJo', 'ATo', 'KQo', 'KJo', 'QJo', 'JTo',
    },
    '3bet': {
      'AA', 'KK', 'QQ', 'JJ', 'AKs', 'AQs', 'AJs', 'A5s', 'A4s', 'A3s',
      'KQs', 'QJs',
      'AKo', 'AQo', 'AJo',
    },
    'call': {
      'TT', '99', '88', '77', 'ATs', 'A9s', 'KJs', 'KTs', 'QTs',
      'JTs', 'T9s', '98s',
      'ATo', 'KJo', 'QJo',
    },
  },

  // ── SB (~40% of hands, adjusted for OOP post-flop) ───────────────────────
  'SB': {
    'open': {
      // All pairs
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44',
      '33', '22',
      // All suited aces
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s',
      'A4s', 'A3s', 'A2s',
      // Suited kings
      'KQs', 'KJs', 'KTs', 'K9s',
      // Suited queens
      'QJs', 'QTs',
      // Suited connectors
      'JTs', 'T9s', '98s', '87s', '76s', '65s',
      // Offsuit broadways
      'AKo', 'AQo', 'AJo', 'ATo', 'KQo', 'KJo', 'QJo',
    },
    '3bet': {
      'AA', 'KK', 'QQ', 'JJ', 'AKs', 'AQs', 'AJs', 'A5s', 'A4s',
      'KQs', 'QJs',
      'AKo', 'AQo', 'AJo',
    },
    'call': {
      'TT', '99', '88', '77', 'ATs', 'A9s', 'KJs', 'KTs',
      'JTs', 'T9s',
      'ATo', 'KJo', 'QJo',
    },
  },

  // ── BB (no open; only 3-bet or call vs open) ──────────────────────────────
  'BB': {
    'open': {},
    '3bet': {
      'AA', 'KK', 'QQ', 'JJ', 'AKs', 'AQs', 'AJs', 'A5s', 'A4s', 'A3s',
      'KQs', 'QJs', 'JTs',
      'AKo', 'AQo', 'AJo',
    },
    'call': {
      // BB defends wide vs single raise (pot odds + position in BB)
      'TT', '99', '88', '77', '66', '55', '44', '33', '22',
      'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A2s',
      'KJs', 'KTs', 'K9s', 'K8s',
      'QTs', 'Q9s',
      'JTs', 'J9s', 'T9s', 'T8s', '98s', '97s', '87s', '86s', '76s',
      '75s', '65s', '64s', '54s',
      'ATo', 'A9o', 'A8o',
      'KQo', 'KJo', 'KTo',
      'QJo', 'QTo', 'JTo',
    },
  },
};
