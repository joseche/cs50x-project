# Chess Puzzles

#### Video Demo: https://youtu.be/IcPGoaDLKFA

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
[https://database.lichess.org/#puzzles]
[https://database.lichess.org/lichess_db_puzzle.csv.zst]

### Format of the lichess DB

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

## Code details

This is my first time using Lua and Love2d. I watched a few videos from Colton Ogden and other and started coding. The structure of the project is very basic, following what seems to be standard for love2d games.

### conf.lua

This is a standard configuration file to enable some features in love2d. I don't have any logic in this file.

### utils.lua

I found that Lua was missing some basic functionality that I wrote in this file, nothing related to the game logic; only helper functions.

### settings.lua

The game calculates many variables to adapt to different screen sizes, although at the moment I am only allowing fullscreen or one non-fullscreen size, so there is a lot of logic about adjusting sizes, fonts, and coordinates relative to the screen size, that is the purpose of this file.

### globals.lua

Values that are not relative to the current screen.

### main.lua

This is the file for love2d, where the callbacks are. I tried to keep all the game logic in game.lua so this file has minimal code.

### game.lua

All the game logic is here and also many global variables. Since the game only uses one board, the state of the whole game is captured here. I define global variables to keep the state, and the logic.

The most relevant functions in this file are described below:

`game.update_rating` uses a [bit of theory](https://en.wikipedia.org/wiki/Elo_rating_system) to adjust the points earned or lost depending on the current user rating and the rating of the puzzle.

`game.valid_piece_turn` takes a piece and decides if its a valid piece to move in the current turn. [It uses UCI](https://en.wikipedia.org/wiki/Universal_Chess_Interface) format.

`game.draw_main_menu` uses the `Main_menu` table to draw the menu on the right, basically using rectangles and printing strings over the rectangles.

`game.draw_selected_squares` uses the global variables _SelectedSquare_ and _NewSquare_ to know which squares to highlight and draws a light rectangle with transparency (blendmode) over the squares. It uses a counter and draws the rectangle when the counter is odd. The same blink counter is used for both squares.

`game.highlight_mouse_pointer` basically follows the pointer and calculates which square corresponds to those coordinates, and draws a square on it so that the use has some visual confirmation of where it is.

`game.draw_empty_board` only draws the sprites of the white and black squares. I discovered that finding sprites that look good was a lot harder than I imagined, but the function itself is very simple.

`game.draw_ratings_graph` uses the list of previous ratings and plots a line graph using the last 20 ratings.

`game.draw_level_selector` draws the selector, and if _LevelDropdown.isOpen_ is true, also draws all the options vertically.

`game.load_resolved_puzzles` is necessary so I don't show the same puzzles that the user has already resolved.

`game.load_puzzles_by_rating` loads puzzles as needed if the ones for a given level are not loaded yet.

`game.start_move` takes a move in UCI formatting, converts the UCI formatting into file and rank for origin and destination and makes the piece move. This function also has an _auto-queen_ feature, where every pawn that reaches the opposite rank is promoted to Queen automatically. This is maybe the only logic related to the game of chess in the game, because the rest is only matter of origin to destination squares, no actual chess logic is implemented, so for example _en passant_ moves are not considered in the scope yet.

`game.draw_success_symbol` is basically an overlay on the board, to tell the user how many rating points he earned or lost. One *very* nice feature of this function is that it sets the alpha depending on the _ShowSuccessTimer_ so it fades!

`game.update_blinking`, `game.update_piece_moving` and `game.update_show_success` are called from love.update. Understanding how love.update works, and how its separate from the drawing functions was one of the most important things I learned in this project.

In *update_piece_moving* I struggled a lot to get a smooth transition, and it was resolved by using _elapsed_ and _duration_ and interpolating between origin and target based on the time, *not* interpolating on a given distance interval. I still want to improve it, because I think the way it works is a bit slow at the end of the transition, so you can not select a new piece when it seems like the previous piece already reached the destination, but at the moment I don't know how to fix it.

`game.board_clicked` has a lot of game logic but the logic is not complex.

`game.check_buttons_clicked` basically checks if any of the buttons on the screen was clicked given its coordinates and dimensions.

## Areas of improvement for following versions

- Add a reset option to remove the files where ratings and resolved puzzles are stored.
- Improve the transition, so that it is not so slow at the end.
- Improve the colors and sprites.
- Implement _en passant_
- Improve the promotion, remove the auto-queen feature :)
- Puzzle DB can be compressed, and decompressed when loading.
