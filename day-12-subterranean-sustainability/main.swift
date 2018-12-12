import Foundation

var plantMap = "###.#..#..##.##.###.#.....#.#.###.#.####....#.##..#.#.#..#....##..#.##...#.###.#.#..#..####.#.##.#"
    .enumerated()
    .reduce(into: [Int: Character]()) { (map, char) in map[char.offset] = char.element }

let combinations = """
#.... => .
#.##. => #
..#.. => .
#.#.# => .
.#.## => #
...## => #
##... => #
###.. => #
#..## => .
.###. => .
###.# => #
..... => .
#..#. => .
.#.#. => #
##..# => #
.##.. => .
...#. => .
#.### => .
..### => .
####. => .
#.#.. => #
.##.# => #
.#... => #
##.#. => #
....# => .
..#.# => #
#...# => #
..##. => .
.#..# => #
.#### => .
##### => #
##.## => #
"""
    .components(separatedBy: .newlines)
    .reduce(into: [String: Character]()) { (map, line) in
        let parts = line.components(separatedBy: " => ")
        map[parts[0]] = parts[1].first!
    }

for gen in 1...20 {
    let min = plantMap.filter { $0.value == "#" }.min { $0.key < $1.key }!.key
    let max = plantMap.filter { $0.value == "#" }.max { $0.key < $1.key }!.key
    
    var newMap = [Int: Character]()
    func plant(at: Int) -> Character {
        return plantMap[at] ?? "."
    }
    for pos in (min-2)...(max+2) {
        let pattern = String((pos-2...pos+2).map{plant(at: $0)})
        newMap[pos] = combinations[pattern] ?? "."
    }
    plantMap = newMap
}

let sum = plantMap.reduce(0) {
    $0 + (($1.value == "#") ? $1.key : 0)
}

print("Part 1:")
print(sum)

print("Part 2:")
print("""
Okay, so I've did some printing and saw a recurring pattern.
After 100 generations the output started to increment by 50. The value at gen 100 is 6175.
So I calculated: (50.000.000.000 - 100) * 50 + 6175. Giving:
""")
print ((50000000000 - 100) * 50 + 6175)
