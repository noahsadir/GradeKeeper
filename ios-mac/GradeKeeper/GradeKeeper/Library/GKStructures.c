//
//  GKStructures.c
//  GradeKeeper
//
//  Created by Noah Sadir on 12/18/21.
//

#include "GKStructures.h"
    
struct Course {
    char* className;
}

/*
 
 struct Course: Codable {
     var className: String
     var classCode: String
     var color: Int
     var weight: Double
     var categories: [String: Category]
     var gradeScale: [String: Grade]
     
     init(dictionary: [String: Any]) {
         self.className = dictionary["name"] as? String ?? "Unnamed Course"
         self.classCode = dictionary["code"] as? String ?? ""
         self.color = dictionary["color"] as? Int ?? 0
         self.weight = dictionary["weight"] as? Double ?? 1
         self.categories = [String: Category]()
         self.gradeScale = [String: Grade]()
         
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
     
     init() {
         self.id = "ERR_DATA_PARSE"
         self.message = "Request successful, but returned unparseable data"
         self.code = 500
     }
 }

 struct Gradebook: Codable {
     var courses: [String: Course]
     
     init(dictionary: [String: Any]) {
         self.courses = [String: Course]()
         
         if let courses = dictionary["classes"] as? [String: [String: Any]] {
             for course in courses {
                 self.courses[course.key] = Course(dictionary: course.value)
             }
         }
     }
     
     init() {
         self.courses = [String: Course]()
     }
 }

 struct User: Codable {
     var email: String
     var password: String
     var internalID: String
     var tempToken: String
     var gradebook: Gradebook
     var assignments: [String: Assignment]
     var lastFetch: UInt64
     
     init (email: String, password: String, dictionary: [String: Any]) {
         self.email = email
         self.password = password
         self.internalID = dictionary["internal_id"] as? String ?? ""
         self.tempToken = dictionary["token"] as? String ?? ""
         self.lastFetch = 0
         self.gradebook = Gradebook()
         self.assignments = [String: Assignment]()
     }
     
 }

 */
