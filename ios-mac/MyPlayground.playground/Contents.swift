import UIKit



var arr = [Int]()
var time = [Double]()
var result = 0
var evenCount: Double = 0

/**
for _ in 0...1000000 {
    let die1 = Int.random(in: 1...6)
    let die2 = Int.random(in: 1...6)
    if ((die1 + die2) % 2) == 0 {
        evenCount += 1
    }
}
print(evenCount / 1000000)
**/



var lastWasHeads = false
var largestStreak = 0
var streak = 0
var streaks = [Int: Int]()
var matches = 0
for _ in 0...100 {
    
    for _ in 0...1000 {
        
        var cards = [1,2,3,4,5,6,7,8,9,10,11,12,13,1,2,3,4,5,6,7,8,9,10,11,12,13,1,2,3,4,5,6,7,8,9,10,11,12,13,1,2,3,4,5,6,7,8,9,10,11,12,13]
        let firstIndex = Int.random(in: 0...51)
        let firstCard = cards[firstIndex]
        
        cards.remove(at: firstIndex)
        let secondCard = cards[Int.random(in: 0...50)]
        
        if firstCard == secondCard {
            matches += 1
        }
        
        /*
        if Int.random(in: 0...1) == 1 {
            if lastWasHeads {
                streak += 1
                if streak > largestStreak {
                    largestStreak = streak
                }
            } else {
                if streaks[streak] != nil {
                    streaks[streak]! += 1
                } else {
                    streaks[streak] = 1
                }
                streak = 0
                lastWasHeads = true
            }
        } else {
            if !lastWasHeads {
                streak += 1
                if streak > largestStreak {
                    largestStreak = streak
                }
            } else {
                if streaks[streak] != nil {
                    streaks[streak]! += 1
                } else {
                    streaks[streak] = 1
                }
                
                streak = 0
                lastWasHeads = false
            }
        }*/
    }

    
}
print(matches)

/*
print(largestStreak)
*/
/*
for i in 0...1024 {
    
    let binStr = String(i, radix: 2)
    var oneCount = 0
    for char in binStr {
        if char == "1" {
            oneCount += 1
        }
    }
    
    //result += Int.random(in: Int.random(in: Int.random(in: -20...(-10))...Int.random(in: -10...0))...Int.random(in: Int.random(in: 0...10)...Int.random(in: 10...20)))
    arr.append(oneCount)
    time.append(Double(Date().timeIntervalSince1970 - start) * 1000)
}*/

/*
for i in 1...1000 {
    var start = Date().timeIntervalSince1970
    var sum = 0
    
    for j in 1...i {
        sum += j
    }
    
    arr.append(Double(Date().timeIntervalSince1970 - start) * 1000)
}
*/
/*
for i in 0...10 {
    time.removeFirst()
}
 */

streaks.map() {$0}
time.map() {$0}

print(streaks)
print("done!")
