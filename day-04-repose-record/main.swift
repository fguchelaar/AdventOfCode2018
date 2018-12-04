import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

// The timestamp format is year-month-day hour:minute, so sorting can be done alphabetically
let records = input
    .components(separatedBy: .newlines)
    .sorted()

class Guard {
    var id: Int
    var sleeping = [Int: Int]()
    
    init(id: Int) {
        self.id = id
    }
    
    func registerSleep(range: Range<Int>) {
        for i in range {
            sleeping[i] = (sleeping[i] ?? 0) + 1
        }
    }
    
    var totalSleepMinutes: Int {
        return sleeping.values.reduce(0, +)
    }
    
    var mostSleepMinute: (minute: Int, total: Int) {
        let pair = sleeping
            .sorted { $0.value > $1.value }
            .first!
        return (pair.key, pair.value)
    }
}

var guards = [Int: Guard]()
var activeGuardId = -1
var rangeStart = 0

for record in records {
    
    let minute = Int(record[String.Index(encodedOffset: 15)..<String.Index(encodedOffset: 17)])!
    
    if record.contains("Guard") {
        let start = String.Index(encodedOffset: 26)
        let end = record.range(of: " begins shift")?.lowerBound
        activeGuardId = Int(record[start..<end!])!
        rangeStart = 0
    } else if record.contains("falls") {
        rangeStart = minute
    } else {
        let activeGuard = guards[activeGuardId] ?? Guard(id: activeGuardId)
        activeGuard.registerSleep(range: rangeStart..<minute)
        guards[activeGuardId] = activeGuard
    }
}

// Find the guard who sleeps the most
let scenario1Guard = guards
    .max { $0.value.totalSleepMinutes < $1.value.totalSleepMinutes}!
    .value

print("Part 1:")
print(scenario1Guard.id * scenario1Guard.mostSleepMinute.minute)

// Find the guard who sleeps the most in one specific minute
let scenario2Guard = guards
    .max { $0.value.mostSleepMinute.total < $1.value.mostSleepMinute.total}!
    .value

print("Part 2:")
print(scenario2Guard.id * scenario2Guard.mostSleepMinute.minute)
