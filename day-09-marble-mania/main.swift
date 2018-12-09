import Foundation

func solve(players: Int, maxPoints: Int) -> Int {
    var scores = Array(repeating: 0, count: players)
    
    var currentMarble = 0
    var currentPlayer = 0
    var circle = [0]
    var circleCount = 1
    for points in 1...maxPoints {
        
        if points % 23 == 0 {
            currentMarble = ((currentMarble - 7) + circleCount) % circleCount // might improve performance, by keeping the count in a separate variable
            scores[currentPlayer] += circle.remove(at: currentMarble) + points
            circleCount -= 1
        } else {
            currentMarble = ((currentMarble + 1) % circleCount) + 1
            circle.insert(points, at: currentMarble)
            circleCount += 1
        }
        currentPlayer = (currentPlayer + 1) % players
    }
    
    return scores.max()!
}

assert(solve(players: 10, maxPoints: 25) == 32)
assert(solve(players: 10, maxPoints: 1618) == 8317)
assert(solve(players: 13, maxPoints: 7999) == 146373)
assert(solve(players: 17, maxPoints: 1104) == 2764)
assert(solve(players: 21, maxPoints: 6111) == 54718)
assert(solve(players: 30, maxPoints: 5807) == 37305)

print("Part 1:")
print(solve(players: 430, maxPoints: 71588))

print("Part 2 (be aware, takes over 1,5 hours):")
print(solve(players: 430, maxPoints: 7158800))
