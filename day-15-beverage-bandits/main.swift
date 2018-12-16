import Foundation

struct Point: Hashable, Equatable, Comparable, CustomStringConvertible {
    var x: Int
    var y: Int
    
    var description: String {
        return "\(x),\(y)"
    }
    
    var neighbors: [Point] {
        let up = Point(x: x, y: y - 1)
        let right = Point(x: x + 1, y: y)
        let down = Point(x: x, y: y + 1)
        let left = Point(x: x - 1, y: y)
        return [up, left, right, down].sorted()
    }
    
    static func < (lhs: Point, rhs: Point) -> Bool {
        return lhs.y < rhs.y || (lhs.y <= rhs.y && lhs.x < rhs.x)
    }
}

enum Type: Character {
    case goblin = "G"
    case elf = "E"
}

class Player {
    var position: Point
    var type: Type
    var hitPoints: Int = 200
    var attackPower: Int = 3
    
    init(position: Point, type: Type) {
        self.position = position
        self.type = type
    }
}

extension Sequence where Element == Player {
    func player(at: Point) -> Player? {
        return self.first { $0.position == at }
    }
    
    func active() -> (elves: Int, goblins: Int) {
        return self.reduce((0, 0)) { count, player in
            return (elves: count.0 + (player.type == .elf ? 1 : 0), goblins: count.1 + (player.type == .goblin ? 1 : 0))
        }
    }
    
    func enemy(for player: Player) -> Player? {
        let enemies = player.position.neighbors
            .compactMap({ self.player(at: $0) })
            .filter { player.type != $0.type }
        
        
        if enemies.isEmpty {
            return nil
        } else {
            return enemies.min { $0.hitPoints < $1.hitPoints || ($0.hitPoints <= $1.hitPoints && $0.position < $1.position ) }
        }
    }
}

func parse(input: String) -> (cave: [Point: Character], players: [Player]) {
    var players: [Player] = []
    var cave: [Point: Character] = [:]
    
    input
        .components(separatedBy: .newlines)
        .enumerated()
        .forEach { line in
            line.element.enumerated().forEach { character in
                let point = Point(x: character.offset, y: line.offset)
                switch character.element {
                case "G":
                    players.append(Player(position: point, type: .goblin))
                    cave[point] = "."
                case "E":
                    players.append(Player(position: point, type: .elf))
                    cave[point] = "."
                default:
                    cave[point] = character.element
                }
            }
    }
    return (cave, players)
}


func print(cave: [Point: Character], players: [Player]) {
    let maxPoint = cave.keys.reduce(Point(x: 0, y: 0)) { max($0, $1) }
    
    let str: [String] = (0...maxPoint.y).map { y in
        let row: [String] = (0...maxPoint.x).map { x in
            let point = Point(x: x, y: y)
            if let player = players.player(at: point) {
                return "\(player.type.rawValue)"
            } else {
                return "\(cave[point, default: "x"])"
            }
        }
        return row.joined()
    }
    
    print (str.joined(separator: "\n"))
}
func print(cave: [Point: Character], players: [Player], distances: [Point: Int]) {
    let maxPoint = cave.keys.reduce(Point(x: 0, y: 0)) { max($0, $1) }
    
    let str: [String] = (0...maxPoint.y).map { y in
        let row: [String] = (0...maxPoint.x).map { x in
            let point = Point(x: x, y: y)
            if let player = players.player(at: point) {
                return "\(player.type.rawValue)"
            } else {
                if let distance = distances[point] {
                    return "\(distance)"
                }
                return "\(cave[point, default: "x"])"
            }
        }
        return row.joined()
    }
    
    print (str.joined(separator: "\n"))
}


func path(for player: Player, in cave: [Point: Character], with players: [Player]) -> [Point]? {
    
    let target: Type = player.type == .goblin ? .elf : .goblin
    
    func canWalk(on: Point) -> Bool {
        return cave[on] == "." && (players.player(at: on)?.type ?? target) != player.type
    }
    var dist = [Point: Int]()
    
    var visited = Set<Point>()
    var unvisited = Set<Point>() //(dist.keys.map { $0 })
    unvisited.insert(player.position)
    var prev = [Point: Point]()
    
    dist[player.position] = 0
    
    while !unvisited.isEmpty {
        
        let current = dist
            .filter { unvisited.contains($0.key) }
            .min { $0.value < $1.value }!
            .key
        
        unvisited.remove(current)
        visited.insert(current)
        
        let neigbors = current.neighbors.filter { !visited.contains($0) && canWalk(on: $0) }
        
        neigbors.forEach { neigbor in
            unvisited.insert(neigbor)
            let distance = dist[current]! + 1
            
            if distance < dist[neigbor, default: Int.max] {
                dist[neigbor] = distance
                prev[neigbor] = current
            }
            else if distance == dist[neigbor] {
                prev[neigbor] = [current, prev[neigbor]!].sorted().first!
            }
        }
    }
    
    func path(to: Point) -> [Point]? {
        if !prev.keys.contains(to) {
            return nil
        }
        var p = [Point]()
        var u: Point? = to
        
        while u != nil && u != player.position {
            p.insert(u!, at: 0)
            u = prev[u!]
        }
        return p
    }
    
    let pathsToEnemies =
        players.filter { $0.type == target }
            .flatMap { $0.position.neighbors }
            .compactMap { path(to: $0) }
            .map { ($0, $0.count) }
    
    if pathsToEnemies.isEmpty {
        //        print("no reachable enemies")
        return nil
    }
    
    //    print(cave: cave, players: players, distances: dist)
    
    let shortest = pathsToEnemies.map { $0.1 }.min()!
    
    var shortestPaths = pathsToEnemies.filter { $0.1 == shortest }
    
    if shortestPaths.count == 1 {
        return shortestPaths[0].0
    } else {
        return shortestPaths.min { $0.0.last! < $1.0.last! }?.0
    }
}


func solve(file: String) -> Int {
    let input = try! String(contentsOfFile: file).trimmingCharacters(in: .whitespacesAndNewlines)
    
    let parsed = parse(input: input)
    let theCave = parsed.cave
    var thePlayers = parsed.players
    
    //print(cave: cave, players: players)
    
    var round = 0
    func gameOver() -> Bool {
        return thePlayers.active().elves == 0 || thePlayers.active().goblins == 0
    }
    
    while !gameOver() {
        //    print ("still in the game: \(players.active())")
        
        var sorted = thePlayers.sorted { $0.position < $1.position }
        
        while !sorted.isEmpty {
            let player = sorted.removeFirst()
            
            // should we move first?
            if thePlayers.enemy(for: player) == nil {
                if let path = path(for: player, in: theCave, with: thePlayers) {
                    player.position = path[0]
                }
            }
            if let enemy = thePlayers.enemy(for: player) {
                enemy.hitPoints -= player.attackPower
                if enemy.hitPoints <= 0 {
                    //                print("\(enemy.type) died")
                    sorted = sorted.filter { $0.position != enemy.position }
                    thePlayers = thePlayers.filter { $0.position != enemy.position }
                }
            }
            if gameOver() {
                //            print ("After \(round) round(s):")
                //            print(cave: cave, players: players)
                //            print("")
                break
            }
        }
        if sorted.isEmpty {
            round += 1
            //        print ("After \(round) round(s):")
            //        print(cave: cave, players: players)
            //        print("")
        }
    }
    
    print("After \(round)")
    print(cave: theCave, players: thePlayers)
    print("")
    
    thePlayers
        .sorted { $0.position < $1.position }
        .forEach { print("\($0.type.rawValue)(\($0.hitPoints))") }
    
    
    let remaining = thePlayers.reduce(0) { $0 + $1.hitPoints }
    return round * remaining
}

print("\(solve(file: "example1.txt")) - 36334")
print("")
print("\(solve(file: "example2.txt")) - 39514")
print("")
print("\(solve(file: "example3.txt")) - 27755")
print("")
print("\(solve(file: "example4.txt")) - 28944")
print("")
print("\(solve(file: "example5.txt")) - 18740")
print("")

let part1 = solve(file: "input.txt")
print("Part 1:")
print(part1)

//263900 - high
//261261 - low