import Foundation

func solve(part1: Bool) -> Int {
    
    var solutions = Set<Int>()
    var r3_prev = 0
    
    var r1 = 0
    var r3 = 0
    var r4 = 65536
    while (true) {
        r4 = r3 | 65536
        r3 = 2176960
        
        func magic() {
            r1 = r4 & 255
            r3 = r3 + r1
            r3 = r3 & 16777215
            r3 = r3 * 65899
            r3 = r3 & 16777215
        }
        
        repeat {
            magic()
            r4 = r4 / 256
        } while r4 >= 256
        
        magic()
        
        if part1 {
            return r3
        } else {
            if solutions.contains(r3) {
                return r3_prev
            } else {
                solutions.insert(r3)
                r3_prev = r3
            }
        }
    }
}

print("Part 1:")
print(solve(part1: true))

print("Part 2:")
print(solve(part1: false))
