import Foundation

class Node {
    
    var value: Int
    
    var previous: Node!
    var next: Node!

    init(value: Int) {
        self.value = value
        previous = self
        next = self
    }
    
    func append(value: Int) -> Node {
        let new = Node(value: value)
        
        new.previous = self
        new.next = self.next
        
        next.previous = new
        next = new
        
        return new
    }
    
    func remove() -> Node {
        previous.next = next
        next.previous = previous
        return next
    }
}

func solve(players: Int, maxPoints: Int) -> Int {
    var scores = Array(repeating: 0, count: players)
    
    var currentPlayer = 0
    var currentMarble = Node(value: 0)

    for points in 1...maxPoints {
        if points % 23 == 0 {
            (0..<7).forEach { _ in currentMarble = currentMarble.previous }
            scores[currentPlayer] += currentMarble.value + points
            currentMarble = currentMarble.remove()
        } else {
            currentMarble = currentMarble.next.append(value: points)
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

print("Part 2:")
print(solve(players: 430, maxPoints: 7158800))
