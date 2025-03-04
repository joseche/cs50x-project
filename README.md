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

- ΔR = rating change
- P = Puzzle rating
- U = User rating
- K = adjustment factor
- S = score (1 for solving, 0 for failing)
- E = expected probability of solving

> [!NOTE]
> E = 1 / 1 + 10^(P-U)/400

```
$$
\displaystyle\sum_{k=3}^5 k^2=3^2 + 4^2 + 5^2 =50
$$
```