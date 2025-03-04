# Chess Puzzles
#### Video Demo:  <URL HERE>
#### Description:

Chess Puzzles is a game to solve chess puzzles, with a rating system similar to [ELO](https://en.wikipedia.org/wiki/Elo_rating_system).

The main use case goes like this:
The user is presented with a puzzle on the screen. He then selects a move,
and the game responds with another move until the puzzle is solved. If the user
makes a mistake the puzzle is failed and the rating is decreased. If the user makes
all the correct moves and wins the puzzle the rating is increased.

## How is the rating change calculated

Using [ELO](https://en.wikipedia.org/wiki/Elo_rating_system) as a reference:

Where:

### ΔR = Rating Change

$\Delta R = K \times (S - E)$

### Adjustment factor (K)

$K = 40 - \frac{|P - U|}{50}$

### Score (S)

- 1 for solving
- 0 for failing

### Expected probability of solving (E)

$E = \frac{1}{1 + 10^{(P - U)/400}}$

### Puzzle rating (P)

Value taken from the puzzle database.

### User rating (U)

Current user rating, users start with a rating of 1200.
