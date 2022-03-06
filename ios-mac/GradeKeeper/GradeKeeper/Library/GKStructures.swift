//  GKStructures.swift
/*
 Copyright (c) 2021-2022 Noah Sadir

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

// Converts all that JSON data into easy(ish)-to-use Swift structures.

import Foundation

struct Course: Codable {
    var courseName: String
    var courseCode: String?
    var color: Int
    var weight: Double
    var categories: [String: Category]
    var gradeScale: [String: Grade]
    var schedule: [Timeslot]
    var instructor: String?
    var editable: Bool
    var defaultCategoryID: String?
    
    
    init(dictionary: [String: Any]) {
        self.courseName = dictionary["name"] as? String ?? "Unnamed Course"
        self.courseCode = dictionary["code"] as? String
        self.color = dictionary["color"] as? Int ?? 0
        self.weight = dictionary["weight"] as? Double ?? 1
        self.instructor = dictionary["instructor"] as? String
        
        self.categories = [String: Category]()
        self.gradeScale = [String: Grade]()
        self.schedule = [Timeslot]()
        self.editable = false
        
        if let categories = dictionary["categories"] as? [String: [String: Any]] {
            for category in categories {
                self.categories[category.key] = Category(dictionary: category.value)
            }
        }
        
        if let grades = dictionary["grade_scale"] as? [String: [String: Any]] {
            for grade in grades {
                self.gradeScale[grade.key] = Grade(dictionary: grade.value)
            }
        }
        
        if let timeslots = dictionary["timeslots"] as? [[String: Any]] {
            for timeslot in timeslots {
                self.schedule.append(Timeslot(dictionary: timeslot))
            }
            
            // sort categories
            self.schedule = self.schedule.sorted { (first, second) -> Bool in
                if first.dayOfWeek != second.dayOfWeek {
                    return first.dayOfWeek < second.dayOfWeek
                } else if first.startTime != second.startTime {
                    return first.startTime < second.startTime
                } else if first.endTime != second.endTime {
                    return first.endTime < second.endTime
                }
                return false
            }
        }
    }
    
    init(courseName: String?, courseCode: String?, color: Int?, weight: Double?) {
        self.courseName = courseName ?? "Unnamed Course"
        self.courseCode = courseCode ?? ""
        self.color = color ?? 0
        self.weight = weight ?? 1
        self.categories = [String: Category]()
        self.gradeScale = [String: Grade]()
        self.schedule = [Timeslot]()
        self.editable = false
    }
}

struct Timeslot: Codable {
    var dayOfWeek: Int
    var startTime: Int
    var endTime: Int
    var startDate: UInt64?
    var endDate: UInt64?
    var description: String
    var address: String?
    
    init(dictionary: [String: Any]) {
        self.dayOfWeek = dictionary["day_of_week"] as? Int ?? 0
        self.startTime = dictionary["start_time"] as? Int ?? 0
        self.endTime = dictionary["end_time"] as? Int ?? 0
        self.startDate = dictionary["start_date"] as? UInt64
        self.endDate = dictionary["end_date"] as? UInt64
        self.description = dictionary["description"] as? String ?? ""
        self.address = dictionary["address"] as? String
    }
}

struct Category: Codable {
    var name: String
    var dropCount: Int
    var weight: Double
    var assignmentIDs: [String]
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["category_name"] as? String ?? "Unnamed Category"
        self.dropCount = dictionary["drop_count"] as? Int ?? 0
        self.weight = dictionary["weight"] as? Double ?? 1
        
        if let assignmentIDs = dictionary["assignments"] as? [String] {
            self.assignmentIDs = assignmentIDs
        } else {
            self.assignmentIDs = [String]()
        }
    }
}

struct Grade: Codable {
    var minScore: Double
    var maxScore: Double?
    var credit: Double
    
    init(dictionary: [String: Any]) {
        self.minScore = dictionary["min_score"] as? Double ?? 0
        self.maxScore = dictionary["max_score"] as? Double
        self.credit = dictionary["credit"] as? Double ?? 1
    }
    
    init(minScore: Double, maxScore: Double?, credit: Double?) {
        self.minScore = minScore
        self.maxScore = maxScore
        self.credit = credit ?? 1
    }
}

struct Assignment: Codable {
    var title: String
    var description: String
    var gradeID: String?
    var actScore: Double?
    var maxScore: Double?
    var weight: Double
    var penalty: Double
    var dueDate: UInt64?
    var assignDate: UInt64?
    var gradedDate: UInt64?
    var modifyDate: UInt64
    
    init(dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? "Untitled"
        self.description = dictionary["description"] as? String ?? ""
        self.gradeID = dictionary["grade_id"] as? String
        self.actScore = dictionary["act_score"] as? Double
        self.maxScore = dictionary["max_score"] as? Double
        self.weight = dictionary["weight"] as? Double ?? 1
        self.penalty = dictionary["penalty"] as? Double ?? 0
        self.dueDate = dictionary["due_date"] as? UInt64
        self.assignDate = dictionary["assign_date"] as? UInt64
        self.gradedDate = dictionary["graded_date"] as? UInt64
        self.modifyDate = dictionary["modify_date"] as? UInt64 ?? 0
    }
    
    init(title: String?, description: String?, gradeID: String?, actScore: Double?, maxScore: Double?, weight: Double?, penalty: Double?, dueDate: UInt64?, assignDate: UInt64?, gradedDate: UInt64?) {
        self.title = title ?? "Untitled"
        self.description = description ?? ""
        self.gradeID = gradeID
        self.actScore = actScore
        self.maxScore = maxScore
        self.weight = weight ?? 1
        self.penalty = penalty ?? 0
        self.dueDate = dueDate
        self.assignDate = assignDate
        self.gradedDate = gradedDate
        self.modifyDate = UInt64(Date().timeIntervalSince1970)
    }
}

struct APIError: Codable {
    var id: String
    var message: String
    var code: Int
    
    init(dictionary: [String: Any], code: Int) {
        self.id = dictionary["error"] as! String
        self.message = dictionary["message"] as! String
        self.code = code
    }
    
    init(id: String, message: String, code: Int) {
        self.id = id
        self.message = message
        self.code = code
    }
    
    init() {
        self.id = "ERR_DATA_PARSE"
        self.message = "Request successful, but returned unparseable data"
        self.code = 500
    }
}

struct Term: Codable {
    var title: String
    var startDate: UInt64?
    var endDate: UInt64?
    var courseIDs: [String]
    
    init(title: String, startDate: UInt64?, endDate: UInt64?) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.courseIDs = [String]()
    }
    
    init(dictionary: [String: Any]) {
        self.title = dictionary["term_title"] as? String ?? ""
        self.startDate = dictionary["start_date"] as? UInt64
        self.endDate = dictionary["end_date"] as? UInt64
        self.courseIDs = dictionary["class_ids"] as? [String] ?? []
    }
}

struct User: Codable {
    var email: String
    var password: String
    var internalID: String
    var tempToken: String
    var courses: [String: Course]
    var assignments: [String: Assignment]
    var terms: [String: Term]
    var lastFetch: UInt64
    var isLocal: Bool
    
    init () {
        self.email = "local"
        self.password = ""
        self.internalID = "local"
        self.tempToken = "local"
        self.lastFetch = 0
        self.assignments = [String: Assignment]()
        self.courses = [String: Course]()
        self.terms = [String: Term]()
        self.isLocal = true
    }
    
    init (email: String, password: String, dictionary: [String: Any]) {
        self.email = email
        self.password = password
        self.internalID = dictionary["internal_id"] as? String ?? ""
        self.tempToken = dictionary["token"] as? String ?? ""
        self.lastFetch = 0
        self.assignments = [String: Assignment]()
        self.courses = [String: Course]()
        self.terms = [String: Term]()
        self.isLocal = false
    }
    
    func configClasses(dictionary: [String: Any]) -> [String: Course] {
        var newCourses = [String: Course]()
        
        if let courseDicts = dictionary["classes"] as? [String: [String: Any]] {
            for courseDict in courseDicts {
                var defaultCatID: String?
                if let existingCourse = self.courses[courseDict.key] {
                    defaultCatID = existingCourse.defaultCategoryID
                }
                newCourses[courseDict.key] = Course(dictionary: courseDict.value)
                newCourses[courseDict.key]?.defaultCategoryID = defaultCatID
            }
        }
        return newCourses
    }
    
    func configTerms(dictionary: [String: Any]) -> [String: Term] {
        var newTerms = [String: Term]()
        if let terms = dictionary as? [String: [String: Any]] {
            for term in terms {
                newTerms[term.key] = Term(dictionary: term.value)
            }
        }
        return newTerms
    }
    
}
