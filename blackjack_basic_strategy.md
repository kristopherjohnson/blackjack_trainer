# Blackjack Basic Strategy

**Assumptions:** 4-8 decks, dealer stands on soft 17, double after split allowed, surrender not allowed

## Hard Totals (No Ace or Ace counts as 1)

| Player Hand | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | A |
|-------------|---|---|---|---|---|---|---|---|----|----|
| 8 or less   | H | H | H | H | H | H | H | H | H  | H  |
| 9           | H | D | D | D | D | H | H | H | H  | H  |
| 10          | D | D | D | D | D | D | D | D | H  | H  |
| 11          | D | D | D | D | D | D | D | D | D  | H  |
| 12          | H | H | S | S | S | H | H | H | H  | H  |
| 13          | S | S | S | S | S | H | H | H | H  | H  |
| 14          | S | S | S | S | S | H | H | H | H  | H  |
| 15          | S | S | S | S | S | H | H | H | H  | H  |
| 16          | S | S | S | S | S | H | H | H | H  | H  |
| 17+         | S | S | S | S | S | S | S | S | S  | S  |

## Soft Totals (Ace counts as 11)

| Player Hand | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | A |
|-------------|---|---|---|---|---|---|---|---|----|----|
| A,2 (13)    | H | H | H | D | D | H | H | H | H  | H  |
| A,3 (14)    | H | H | H | D | D | H | H | H | H  | H  |
| A,4 (15)    | H | H | D | D | D | H | H | H | H  | H  |
| A,5 (16)    | H | H | D | D | D | H | H | H | H  | H  |
| A,6 (17)    | H | D | D | D | D | H | H | H | H  | H  |
| A,7 (18)    | S | D | D | D | D | S | S | H | H  | H  |
| A,8 (19)    | S | S | S | S | S | S | S | S | S  | S  |
| A,9 (20)    | S | S | S | S | S | S | S | S | S  | S  |

## Pairs

| Player Hand | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | A |
|-------------|---|---|---|---|---|---|---|---|----|----|
| A,A         | Y | Y | Y | Y | Y | Y | Y | Y | Y  | Y  |
| 10,10       | N | N | N | N | N | N | N | N | N  | N  |
| 9,9         | Y | Y | Y | Y | Y | N | Y | Y | N  | N  |
| 8,8         | Y | Y | Y | Y | Y | Y | Y | Y | Y  | Y  |
| 7,7         | Y | Y | Y | Y | Y | Y | N | N | N  | N  |
| 6,6         | Y | Y | Y | Y | Y | N | N | N | N  | N  |
| 5,5         | N | N | N | N | N | N | N | N | N  | N  |
| 4,4         | N | N | N | Y | Y | N | N | N | N  | N  |
| 3,3         | Y | Y | Y | Y | Y | Y | N | N | N  | N  |
| 2,2         | Y | Y | Y | Y | Y | Y | N | N | N  | N  |

## Legend
- **H** = Hit
- **S** = Stand  
- **D** = Double (if not allowed, then Hit)
- **Y** = Split
- **N** = Don't Split

## Key Strategy Points
1. Never take insurance
2. Always split Aces and 8s
3. Never split 10s, 5s, or 4s (except 4,4 vs 5,6)
4. Double 11 against everything except Ace
5. Double 10 against 2-9
6. Stand on hard 17+
7. Stand on soft 19+