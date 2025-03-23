# Chess Puzzles

#### Video Demo:  `<URL HERE>`

#### Description

Chess Puzzles is a lua game to solve chess puzzles, with a rating system similar to [ELO](https://en.wikipedia.org/wiki/Elo_rating_system).

## Main Use Case

The user is presented with a puzzle on the screen. He then selects a move,
and the game responds with another move until the puzzle is solved. If the user
makes a mistake the puzzle is failed and the rating is decreased. If the user makes
all the correct moves and wins the puzzle the rating is increased, and the game selects a new puzzle. The user can skip the puzzle, or get a hint.

### How is the rating change calculated

The user rating is updated based on the following formulas:

#### ΔR = Rating Change

$\Delta R = K \times (S - E)$

#### Adjustment factor (K)

$K = 40 - \frac{|P - U|}{50}$

#### Score (S)

- 1 for solving (without hints)
- 1/(number of hints used)
- 0 for failing

#### Expected probability of solving (E)

$E = \frac{1}{1 + 10^{(P - U)/400}}$

#### Puzzle rating (P)

Value taken from the puzzle database.

#### User rating (U)

Current user rating, users start with a rating of 600.

## Puzzle Database

The database used is available under the Creative Common CC0 1.0 Universal license.
https://database.lichess.org/#puzzles
https://database.lichess.org/lichess_db_puzzle.csv.zst


### Format

Puzzles are formatted as standard CSV. The fields are as follows:

```csv
PuzzleId,FEN,Moves,Rating,RatingDeviation,Popularity,NbPlays,Themes,GameUrl,OpeningTags
```

### Sample

```csv
00sHx,q3k1nr/1pp1nQpp/3p4/1P2p3/4P3/B1PP1b2/B5PP/5K2 b k - 0 17,e8d7 a2e6 d7d8 f7f8,1760,80,83,72,mate mateIn2 middlegame short,https://lichess.org/yyznGmXs/black#34,Italian_Game Italian_Game_Classical_Variation
00sJb,Q1b2r1k/p2np2p/5bp1/q7/5P2/4B3/PPP3PP/2KR1B1R w - - 1 17,d1d7 a5e1 d7d1 e1e3 c1b1 e3b6,2235,76,97,64,advantage fork long,https://lichess.org/kiuvTFoE#33,Sicilian_Defense Sicilian_Defense_Dragon_Variation
00sO1,1k1r4/pp3pp1/2p1p3/4b3/P3n1P1/8/KPP2PN1/3rBR1R b - - 2 31,b8c7 e1a5 b7b6 f1d1,998,85,94,293,advantage discoveredAttack master middlegame short,https://lichess.org/vsfFkG0s/black#62,
```

