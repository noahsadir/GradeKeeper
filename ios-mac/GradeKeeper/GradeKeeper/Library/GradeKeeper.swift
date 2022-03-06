//  GradeKeeper.swift
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

// (This is where the magic happens)

import Foundation
import UIKit


class GradeKeeper {
    
    var baseURL = "https://gradekeeper.noahsadir.io/api/"
    var urlSuffix = ""
    
    static var currentUser = User(email: "", password: "", dictionary: [:])
    //static var currentUser = User()
    static var selectedCourseID = ""
    static var selectedAssignmentID = ""
    static var selectedCategoryID = ""
    static var selectedTermID = ""
    static var selectedTimeslotIndex = -1
    static var themeColor = UIColor.systemIndigo
    

    
    class user: GradeKeeper {
        
        /// Create a new user
        ///
        /// Example of a typical implementation
        /// ```
        /// GradeKeeper.user().create(email: "name@example.com", password: "Abc123!") { (success, error) in
        ///     if (success) {
        ///         // handle success
        ///     } else {
        ///         print(error!.id)
        ///         print(error!.message)
        ///     }
        /// }
        /// ```
        ///
        /// - Parameters:
        ///     - email: The desired email for the new user
        ///     - password: The desired password for the new user
        ///     - callback: The closure which is called after the request is completed
        ///     - success: Indicates whether or not request was successful
        ///     - error: Contains the error ID and human-friendly message if the request fails.
        ///
        ///        *NOTE:* If the request was successful, `error == nil`
        func create(email: String, password: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            GKCalls().createUser(email: email, password: password) { (success, result, error) in
                callback(success, error)
            }
        }
        
        /// Authenticate an existing user
        ///
        /// Example of a typical implementation
        /// ```
        /// GradeKeeper.user().authenticate(email: "name@example.com", password: "Abc123!") { (success, error) in
        ///     if (success) {
        ///         // handle success
        ///     } else {
        ///         print(error!.id)
        ///         print(error!.message)
        ///     }
        /// }
        /// ```
        ///
        /// - Parameters:
        ///     - email: The desired email for the new user
        ///     - password: The desired password for the new user
        ///     - callback: The closure which is called after the request is completed
        ///     - success: Indicates whether or not request was successful
        ///     - user: The credentials for the newly authenticated user
        ///
        ///        *NOTE:* If the request was unsuccessful, `user == nil`
        ///     - error: Contains the error ID and human-friendly message if the request fails.
        ///
        ///        *NOTE:* If the request was successful, `error == nil`
        func authenticate(email: String, password: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if (!GradeKeeper.currentUser.isLocal) {
                GKCalls().authenticateUser(email: email, password: password) { (success, result, error) in
                    if success {
                        GradeKeeper.currentUser = User(email: email, password: password, dictionary: result!)
                    }
                    callback(success, error)
                }
            } else {
                print("User is local; no auth needed")
            }
        }
    }
    
    class category: GradeKeeper {
        
        /// Create a new category
        ///
        /// Example of a typical implementation
        /// ```
        /// GradeKeeper.category().create(courseID: "0123456789abcdef", categoryName: "Homework", weight: 25, dropCount: 3) { (success, error) in
        ///     if (success) {
        ///         // handle success
        ///     } else {
        ///         print(error!.id)
        ///         print(error!.message)
        ///     }
        /// }
        /// ```
        ///
        /// - Parameters:
        ///     - email: The desired email for the new user
        ///     - password: The desired password for the new user
        ///     - callback: The closure which is called after the request is completed
        ///         - `success` Indicates whether or not request was successful
        ///         - `error` Contains the error ID and human-friendly message if the request fails.
        ///
        ///        *NOTE:* If the request was successful, `error == nil`
        func create(courseID: String, categoryName: String, weight: Double, dropCount: Int, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let _ = GradeKeeper.currentUser.courses[courseID] {
                    GradeKeeper.currentUser.courses[courseID]!.categories["localcat_" + String(Date().timeIntervalSince1970)] = Category(dictionary: ["category_name": categoryName, "drop_count": dropCount, "weight": weight, "assignments": [String]()])
                    callback(true, nil)
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().createCategory(&GradeKeeper.currentUser, courseID: courseID, categoryName: categoryName, dropCount: dropCount, weight: weight) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (loadSuccess, loadErr) in
                            callback(loadSuccess, loadErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        /// Modify an existing category
        ///
        /// Example of a typical implementation
        /// ```
        /// GradeKeeper.category().modify(courseID: "0123456789abcdef", categoryID: "0123456789abcdef", categoryName: "Homework", weight: 25, dropCount: 3) { (success, error) in
        ///     if (success) {
        ///         // handle success
        ///     } else {
        ///         print(error!.id)
        ///         print(error!.message)
        ///     }
        /// }
        /// ```
        ///
        /// - Parameters:
        ///     - email: The desired email for the new user
        ///     - password: The desired password for the new user
        ///     - callback: The closure which is called after the request is completed
        ///         - `success` Indicates whether or not request was successful
        ///         - `error` Contains the error ID and human-friendly message if the request fails.
        ///
        ///        *NOTE:* If the request was successful, `error == nil`
        func modify(courseID: String, categoryID: String, categoryName: String, weight: Double, dropCount: Int, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let _ = course.categories[categoryID] {
                        GradeKeeper.currentUser.courses[courseID]!.categories[categoryID] = Category(dictionary: ["category_name": categoryName, "drop_count": dropCount, "weight": weight, "assignments": [String]()])
                        callback(true, nil)
                    } else {
                        callback(false, APIError(id: "LOC_ERR_INVALID_CATEGORY", message: "The specified category does not exist.", code: 400))
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().modifyCategory(&GradeKeeper.currentUser, courseID: courseID, categoryID: categoryID, categoryName: categoryName, dropCount: dropCount, weight: weight) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (loadSuccess, loadErr) in
                            callback(loadSuccess, loadErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func delete(courseID: String, categoryID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let category = course.categories[categoryID] {
                        for assignmentID in category.assignmentIDs {
                            GradeKeeper.currentUser.assignments.removeValue(forKey: assignmentID)
                        }
                        GradeKeeper.currentUser.courses[courseID]!.categories.removeValue(forKey: categoryID)
                        callback(true, nil)
                    } else {
                        callback(false, APIError(id: "LOC_ERR_INVALID_CATEGORY", message: "The specified category does not exist.", code: 400))
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().deleteCategory(&GradeKeeper.currentUser, courseID: courseID, categoryID: categoryID) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (loadSuccess, loadErr) in
                            callback(loadSuccess, loadErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func sorted(course: Course) -> [String] {
            var categoryIDs = Array(course.categories.keys) as [String]
            
            // sort categories
            categoryIDs = categoryIDs.sorted { (first, second) -> Bool in
                if let firstCat = course.categories[first], let secondCat = course.categories[second] {
                    if firstCat.weight != secondCat.weight {
                        return firstCat.weight < secondCat.weight
                    }
                    return firstCat.name < secondCat.name
                }
                return first < second
            }
            return categoryIDs
        }
    }
    
    class grade: GradeKeeper {
        
        func create(courseID: String, gradeID: String, minScore: Double, maxScore: Double?, credit: Double, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let _ = course.gradeScale[gradeID] {
                        callback(false, APIError(id: "LOC_ERR_GRADE_EXISTS", message: "The grade already exists.", code: 400))
                    } else {
                        GradeKeeper.currentUser.courses[courseID]!.gradeScale[gradeID] = Grade(minScore: minScore, maxScore: maxScore, credit: credit)
                        callback(true, nil)
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().createGrade(&GradeKeeper.currentUser, courseID: courseID, gradeID: gradeID, minScore: minScore, maxScore: maxScore, credit: credit) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (loadSuccess, loadErr) in
                            callback(loadSuccess, loadErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
            
        }
        
        func modify(courseID: String, gradeID: String, minScore: Double, maxScore: Double?, credit: Double, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let _ = course.gradeScale[gradeID] {
                        GradeKeeper.currentUser.courses[courseID]!.gradeScale[gradeID] = Grade(minScore: minScore, maxScore: maxScore, credit: credit ?? 1)
                        callback(true, nil)
                    } else {
                        callback(false, APIError(id: "LOC_ERR_INVALID_GRADE", message: "The specified grade does not exist.", code: 400))
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().modifyGrade(&GradeKeeper.currentUser, courseID: courseID, gradeID: gradeID, minScore: minScore, maxScore: maxScore, credit: credit) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (loadSuccess, loadErr) in
                            callback(loadSuccess, loadErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func delete(courseID: String, gradeID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let _ = course.gradeScale[gradeID] {
                        GradeKeeper.currentUser.courses[courseID]!.gradeScale.removeValue(forKey: gradeID)
                        callback(true, nil)
                    } else {
                        callback(false, APIError(id: "LOC_ERR_INVALID_GRADE", message: "The specified grade does not exist.", code: 400))
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().deleteGrade(&GradeKeeper.currentUser, courseID: courseID, gradeID: gradeID) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (loadSuccess, loadErr) in
                            callback(loadSuccess, loadErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
    }
    
    class assignments: GradeKeeper {
        
        func load(courseID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                GradeKeeper.storage.user().save()
                callback(true, nil)
            } else {
                GKCalls().getAssignments(&GradeKeeper.currentUser, courseID: courseID, ignoreBeforeDate: nil) { (success, result, error) in
                    if success {
                        if let assignments = result!["assignments"] as? [String: [String: Any]] {
                            GradeKeeper.currentUser.assignments = [String: Assignment]()
                            for assignmentItem in assignments {
                                GradeKeeper.currentUser.assignments[assignmentItem.key] = Assignment(dictionary: assignmentItem.value)
                            }
                            GradeKeeper.storage.user().save()
                            callback(true, nil)
                        } else {
                            callback(false, APIError())
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func create(courseID: String, categoryID: String, title: String?, description: String?, gradeID: String?, actScore: Double?, maxScore: Double?, weight: Double?, penalty: Double?, dueDate: UInt64?, assignDate: UInt64?, gradedDate: UInt64?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let _ = course.categories[categoryID] {
                        let assignmentID = "localasg_" + String(Date().timeIntervalSince1970);
                        if let _ = GradeKeeper.currentUser.assignments[assignmentID] {
                            callback(false, APIError(id: "LOC_ERR_ASSIGNMENT_EXISTS", message: "The assignment already exists.", code: 400))
                        } else {
                            GradeKeeper.currentUser.courses[courseID]!.categories[categoryID]!.assignmentIDs.append(assignmentID)
                            GradeKeeper.currentUser.assignments[assignmentID] = Assignment(title: title, description: description, gradeID: gradeID, actScore: actScore, maxScore: maxScore, weight: weight, penalty: penalty, dueDate: dueDate, assignDate: assignDate, gradedDate: gradedDate)
                            callback(true, nil)
                        }
                    } else {
                        callback(false, APIError(id: "LOC_ERR_INVALID_CATEGORY", message: "The specified category does not exist.", code: 400))
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().createAssignment(&GradeKeeper.currentUser, courseID: courseID, categoryID: categoryID, title: title, description: description, gradeID: gradeID, actScore: actScore, maxScore: maxScore, weight: weight, penalty: penalty, dueDate: dueDate, assignDate: assignDate, gradedDate: gradedDate) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (crsSuccess, crsErr) in
                            if crsSuccess {
                                GradeKeeper.assignments().load(courseID: courseID) { (asgSuccess, asgErr) in
                                    callback(asgSuccess, asgErr)
                                }
                            } else {
                                callback(crsSuccess, crsErr)
                            }
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func modify(courseID: String, categoryID: String, assignmentID: String, title: String?, description: String?, gradeID: String?, actScore: Double?, maxScore: Double?, weight: Double?, penalty: Double?, dueDate: UInt64?, assignDate: UInt64?, gradedDate: UInt64?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    if let _ = course.categories[categoryID] {
                        if let _ = GradeKeeper.currentUser.assignments[assignmentID] {
                            GradeKeeper.currentUser.assignments[assignmentID] = Assignment(title: title, description: description, gradeID: gradeID, actScore: actScore, maxScore: maxScore, weight: weight, penalty: penalty, dueDate: dueDate, assignDate: assignDate, gradedDate: gradedDate)
                            callback(true, nil)
                        } else {
                            callback(false, APIError(id: "LOC_ERR_INVALID_ASSIGNMENT", message: "The specified assignment does not exist.", code: 400))
                        }
                    } else {
                        callback(false, APIError(id: "LOC_ERR_INVALID_CATEGORY", message: "The specified category does not exist.", code: 400))
                    }
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().modifyAssignment(&GradeKeeper.currentUser, courseID: courseID, categoryID: categoryID, assignmentID: assignmentID, title: title, description: description, gradeID: gradeID, actScore: actScore, maxScore: maxScore, weight: weight, penalty: penalty, dueDate: dueDate, assignDate: assignDate, gradedDate: gradedDate) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (crsSuccess, crsErr) in
                            if crsSuccess {
                                GradeKeeper.assignments().load(courseID: courseID) { (asgSuccess, asgErr) in
                                    callback(asgSuccess, asgErr)
                                }
                            } else {
                                callback(crsSuccess, crsErr)
                            }
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
            
        }
        
        func delete(courseID: String, assignmentID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            
            if GradeKeeper.currentUser.isLocal {
                GradeKeeper.currentUser.assignments.removeValue(forKey: assignmentID)
                
                // Remove assignment from category
                if let course = GradeKeeper.currentUser.courses[courseID] {
                    for category in course.categories {
                        if category.value.assignmentIDs.contains(assignmentID) {
                            GradeKeeper.currentUser.courses[courseID]!.categories[category.key]!.assignmentIDs = category.value.assignmentIDs.filter {$0 != assignmentID}
                            break
                        }
                    }
                }
                
                callback(true, nil)
            } else {
                GKCalls().deleteAssignment(&GradeKeeper.currentUser, courseID: courseID, assignmentID: assignmentID) { (success, result, error) in
                    if success {
                        GradeKeeper.assignments().load(courseID: courseID) { (asgSuccess, asgErr) in
                            callback(asgSuccess, asgErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func sorted(course: Course) -> Course {
            var newCourse = course
            let sortedAssignments = GradeKeeper.currentUser.assignments.sorted { (first, second) -> Bool in
                let firstDue = first.value.dueDate ?? 0
                let secondDue = second.value.dueDate ?? 0
                if firstDue != secondDue {
                    return firstDue < secondDue
                }
                return first.value.title < second.value.title
            }
            
            for categoryItem in newCourse.categories {
                var orderedAssignments = [String]()
                for assignmentItem in sortedAssignments {
                    if categoryItem.value.assignmentIDs.contains(assignmentItem.key) {
                        orderedAssignments.append(assignmentItem.key)
                    }
                }
                newCourse.categories[categoryItem.key]!.assignmentIDs = orderedAssignments
            }
            return newCourse
        }
        
        
    }
    
    class courses: GradeKeeper {
        
        func load(callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                GradeKeeper.storage.user().save()
                callback(true, nil)
            } else {
                GKCalls().getCourses(&GradeKeeper.currentUser) { (success, result, error) in
                    if success {
                        if let gradebook = result!["gradebook"] as? [String: Any] {
                            GradeKeeper.currentUser.courses = GradeKeeper.currentUser.configClasses(dictionary: gradebook)
                            GradeKeeper.terms().load() { (trmSuccess, trmError) in
                                GradeKeeper.storage.user().save()
                                callback(trmSuccess, trmError)
                            }
                        } else {
                            callback(false, APIError())
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func create(termID: String?, courseName: String, courseCode: String?, color: Int?, weight: Double?, instructor: String?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                let courseID = "localcrs_" + String(Date().timeIntervalSince1970);
                if let _ = GradeKeeper.currentUser.courses[courseID] {
                    callback(false, APIError(id: "LOC_ERR_COURSE_EXISTS", message: "The course already exists.", code: 400))
                } else {
                    GradeKeeper.currentUser.courses[courseID] = Course(courseName: courseName, courseCode: courseCode, color: color, weight: weight)
                    callback(true, nil)
                }
                
            } else {
                GKCalls().createCourse(&GradeKeeper.currentUser, termID: termID, courseName: courseName, courseCode: courseCode, color: color, weight: weight, instructor: instructor) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (crsSuccess, crsErr) in
                            if crsSuccess {
                                GradeKeeper.terms().load() { (trmSuccess, trmErr) in
                                    callback(trmSuccess, trmErr)
                                }
                            } else {
                                callback(crsSuccess, crsErr)
                            }
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func modify(courseID: String, termID: String?, courseName: String, courseCode: String?, color: Int?, weight: Double?, instructor: String?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let _ = GradeKeeper.currentUser.courses[courseID] {
                    GradeKeeper.currentUser.courses[courseID]!.courseName = courseName
                    GradeKeeper.currentUser.courses[courseID]!.courseCode = courseCode
                    GradeKeeper.currentUser.courses[courseID]!.color = color ?? 0
                    GradeKeeper.currentUser.courses[courseID]!.weight = weight ?? 1
                    callback(true, nil)
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().modifyCourse(&GradeKeeper.currentUser, courseID: courseID, termID: termID, courseName: courseName, courseCode: courseCode, color: color, weight: weight, instructor: instructor) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (crsSuccess, crsErr) in
                            if crsSuccess {
                                GradeKeeper.terms().load() { (trmSuccess, trmErr) in
                                    callback(trmSuccess, trmErr)
                                }
                            } else {
                                callback(crsSuccess, crsErr)
                            }
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func delete(courseID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let _ = GradeKeeper.currentUser.courses[courseID] {
                    GradeKeeper.currentUser.courses.removeValue(forKey: courseID)
                    callback(true, nil)
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().deleteCourse(&GradeKeeper.currentUser, courseID: courseID) { (success, result, error) in
                    if success {
                        GradeKeeper.courses().load() { (crsSuccess, crsErr) in
                            if crsSuccess {
                                GradeKeeper.terms().load() { (trmSuccess, trmErr) in
                                    callback(trmSuccess, trmErr)
                                }
                            } else {
                                callback(crsSuccess, crsErr)
                            }
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func sorted(courses: [String: Course]) -> [String] {
            var courseIDs = Array(courses.keys) as [String]
            // sort categories
            courseIDs = courseIDs.sorted { (first, second) -> Bool in
                if let firstCourse = courses[first], let secondCourse = courses[second] {
                    if let firstCode = firstCourse.courseCode, let secondCode = secondCourse.courseCode {
                        return firstCode < secondCode
                    }
                    return firstCourse.courseName < secondCourse.courseName
                }
                return first < second
            }
            return courseIDs
        }
        
    }
    
    class terms: GradeKeeper {
        
        func load(callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                GradeKeeper.storage.user().save()
                callback(true, nil)
            } else {
                GKCalls().getTerms(&GradeKeeper.currentUser) { (success, result, error) in
                    if success {
                        if let terms = result!["terms"] as? [String: Any] {
                            
                            GradeKeeper.currentUser.terms = GradeKeeper.currentUser.configTerms(dictionary: terms)
                            GradeKeeper.storage.user().save()
                            callback(true, nil)
                        } else {
                            callback(false, APIError())
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func create(termTitle: String, startDate: UInt64?, endDate: UInt64?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                let termID = "localtrm_" + String(Date().timeIntervalSince1970);
                if let _ = GradeKeeper.currentUser.terms[termID] {
                    callback(false, APIError(id: "LOC_ERR_TERM_EXISTS", message: "The term already exists.", code: 400))
                } else {
                    GradeKeeper.currentUser.terms[termID] = Term(title: termTitle, startDate: startDate, endDate: endDate)
                    callback(true, nil)
                }
            } else {
                GKCalls().createTerm(&GradeKeeper.currentUser, termTitle: termTitle, startDate: startDate, endDate: endDate) { (success, result, error) in
                    if success {
                        GradeKeeper.terms().load() { (trmSuccess, trmErr) in
                            callback(trmSuccess, trmErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func modify(termID: String, termTitle: String, startDate: UInt64?, endDate: UInt64?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let _ = GradeKeeper.currentUser.terms[termID] {
                    GradeKeeper.currentUser.terms[termID]!.title = termTitle
                    GradeKeeper.currentUser.terms[termID]!.startDate = startDate
                    GradeKeeper.currentUser.terms[termID]!.endDate = endDate
                    callback(true, nil)
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_TERM", message: "The term does not exist.", code: 400))
                }
            } else {
                GKCalls().modifyTerm(&GradeKeeper.currentUser, termID: termID, termTitle: termTitle, startDate: startDate, endDate: endDate) { (success, result, error) in
                    if success {
                        GradeKeeper.terms().load() { (trmSuccess, trmErr) in
                            callback(trmSuccess, trmErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func delete(termID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let _ = GradeKeeper.currentUser.terms[termID] {
                    GradeKeeper.currentUser.terms.removeValue(forKey: termID)
                    callback(true, nil)
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_TERM", message: "The term does not exist.", code: 400))
                }
            } else {
                GKCalls().deleteTerm(&GradeKeeper.currentUser, termID: termID) { (success, result, error) in
                    if success {
                        GradeKeeper.terms().load() { (trmSuccess, trmErr) in
                            callback(trmSuccess, trmErr)
                        }
                    } else {
                        callback(success, error)
                    }
                }
            }
        }
        
        func sorted(terms: [String: Term]) -> [String] {
            var termIDs = Array(terms.keys) as [String]
            
            // sort categories
            termIDs = termIDs.sorted { (first, second) -> Bool in
                if let firstTerm = terms[first], let secondTerm = terms[second] {
                    if let firstStart = firstTerm.startDate, let secondStart = secondTerm.startDate {
                        return firstStart > secondStart
                    } else if let firstEnd = firstTerm.endDate, let secondEnd = secondTerm.endDate {
                        return firstEnd > secondEnd
                    }
                }
                return first < second
            }
            return termIDs
        }
        
        func forCourseID(courseID: String) -> Term? {
            for term in GradeKeeper.currentUser.terms {
                if term.value.courseIDs.contains(courseID) {
                    return term.value
                }
            }
            return nil
        }
        
        func idFromCourseID(courseID: String) -> String? {
            for term in GradeKeeper.currentUser.terms {
                if term.value.courseIDs.contains(courseID) {
                    return term.key
                }
            }
            return nil
        }
        
    }
    
    
    class calculate: GradeKeeper {
        
        func rawScoreRatioString(_ assignmentItem: Assignment) -> String {
            if let act = assignmentItem.actScore, let max = assignmentItem.maxScore {
                let roundedAct = (act * 100).rounded() / 100
                let roundedMax = (max * 100).rounded() / 100
                return String(roundedAct) + " / " + String(roundedMax)
            }
            return "Awaiting Score"
        }
        
        func adjustedScoreRatioString(_ assignmentItem: Assignment) -> String {
            if let act = adjustedAct(assignmentItem), let max = adjustedMax(assignmentItem) {
                let roundedAct = (act * 100).rounded() / 100
                let roundedMax = (max * 100).rounded() / 100
                return String(roundedAct) + " / " + String(roundedMax)
            }
            return "Awaiting Score"
        }
        
        func rawScorePercentage(_ assignmentItem: Assignment) -> Double? {
            if let act = assignmentItem.actScore, let max = assignmentItem.maxScore {
                let roundedVal = ((act / max) * 10000).rounded() / 100
                return roundedVal
            }
            return nil
        }
        
        func adjustedScorePercentage(_ assignmentItem: Assignment) -> Double? {
            if let act = adjustedAct(assignmentItem), let max = adjustedMax(assignmentItem) {
                let roundedVal = ((act / max) * 10000).rounded() / 100
                return roundedVal
            }
            return nil
        }
        
        func gradeRecieved(_ assignmentItem: Assignment, gradeScale: [String: Grade]) -> String? {
           
            if assignmentItem.gradeID != nil && assignmentItem.gradeID != "" {
                return assignmentItem.gradeID
            } else if let adjPercent = adjustedScorePercentage(assignmentItem) {
                
                var highestMin: Double = 0
                var selectedGradeID: String?
                
                for gradeItem in gradeScale {
                    if adjPercent >= gradeItem.value.minScore && gradeItem.value.minScore > highestMin {
                        if let max = gradeItem.value.maxScore {
                            if adjPercent < max {
                                highestMin = gradeItem.value.minScore
                                selectedGradeID = gradeItem.key
                            }
                        } else {
                            highestMin = gradeItem.value.minScore
                            selectedGradeID = gradeItem.key
                        }
                    }
                }
                
                return selectedGradeID
            }
            return nil
        }
        
        func grade(adjPercent: Double, gradeScale: [String: Grade]) -> String? {
           
            var highestMin: Double = 0
            var selectedGradeID: String?
            
            for gradeItem in gradeScale {
                if adjPercent >= gradeItem.value.minScore && gradeItem.value.minScore > highestMin {
                    if let max = gradeItem.value.maxScore {
                        if adjPercent < max {
                            highestMin = gradeItem.value.minScore
                            selectedGradeID = gradeItem.key
                        }
                    } else {
                        highestMin = gradeItem.value.minScore
                        selectedGradeID = gradeItem.key
                    }
                }
            }
            
            return selectedGradeID
        }
        
        func adjustedAct(_ assignmentItem: Assignment) -> Double? {
            if let act = assignmentItem.actScore, let max = assignmentItem.maxScore {
                return ((((act / max) * 100) - assignmentItem.penalty) * assignmentItem.weight)
            }
            return nil
        }
        
        func adjustedMax(_ assignmentItem: Assignment) -> Double? {
            return 100 * assignmentItem.weight
        }
        
        func dateSecsFormatted(_ dateSecs: UInt64) -> String {
            let dueDate = Date(timeIntervalSince1970: TimeInterval(dateSecs))
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd, yyyy h:mm a"
            return dateFormatterPrint.string(from: dueDate)
        }
        func timeMillisFormatted(_ timeMillis: UInt64) -> String {
            let dueDate = Date(timeIntervalSince1970: TimeInterval(timeMillis / 1000))
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "h:mm a"
            return dateFormatterPrint.string(from: dueDate)
        }
        
    }
    
    
    class storage: GradeKeeper {
        
        class user: storage {
            func save() {
                let jsonEncoder = JSONEncoder()
                let jsonData = try? jsonEncoder.encode(GradeKeeper.currentUser)
                if let jsonData = jsonData {
                    GradeKeeper.storage.appSupport().save(data: jsonData, name: "user", format: "json")
                }
            }
            
            func load() {
                if let jsonData = GradeKeeper.storage.appSupport().load(path: "user.json") {
                    let decoder = JSONDecoder()

                    if let loadedUser = try? decoder.decode(User.self, from: jsonData) {
                        GradeKeeper.currentUser = loadedUser
                    }
                }
            }
        }
        
        class defaults: storage {
            func save(key: String, value: Any) {
                UserDefaults.standard.set(value, forKey: key)
            }
            
            func retrieve(key: String) -> Any? {
                return UserDefaults.standard.object(forKey: key)
            }
        }
        
        class documents: storage {
            func save(data: Data, name: String, format: String) -> URL? {
                let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                let filePath = docDirectory.appendingPathComponent(name + "." + format)
                
                if FileManager.default.fileExists(atPath: filePath.path) {
                    do {
                        try? FileManager.default.removeItem(at: filePath)
                    }
                }
                
                do {
                    try data.write(to: filePath)
                    return filePath
                } catch {
                    return nil
                }
            }
            
            func load(path: String) -> Data? {
                let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = docDirectory.appendingPathComponent(path)
                
                do {
                    if let data = try? Data(contentsOf: filePath) {
                        return data
                    }
                }
                
                return nil
            }
        }
        
        class appSupport: storage {
            func save(data: Data, name: String, format: String) -> URL? {
                let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                
                let appDirectory = appSupportDirectory.appendingPathComponent("Courseman")
                
                //Create subdirectory if it doesn't exist
                if !FileManager.default.fileExists(atPath:appDirectory.path) {
                    do {
                        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                }
                
                let filePath = appSupportDirectory.appendingPathComponent("Courseman").appendingPathComponent(name + "." + format)
                
                print(filePath)
                if FileManager.default.fileExists(atPath: filePath.path) {
                    do {
                        try? FileManager.default.removeItem(at: filePath)
                    }
                }
                
                do {
                    try data.write(to: filePath)
                    return filePath
                } catch {
                    return nil
                }
            }
            
            func load(path: String) -> Data? {
                let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                let filePath = appSupportDirectory.appendingPathComponent("Courseman").appendingPathComponent(path)
                
                do {
                    if let data = try? Data(contentsOf: filePath) {
                        return data
                    }
                }
                
                return nil
            }
        }
    }
    
    func userToJSON() {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(GradeKeeper.currentUser)
        if let jsonData = jsonData {
            saveTempFile(data: jsonData, format: "json")
            print(String(data: jsonData, encoding: .utf8))
        }
        
    }
    
    func saveTempFile(data: Data, format: String) -> URL? {
        let appSupportDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let tempDirectory = appSupportDirectory.appendingPathComponent("tmp")
        
        //Create subdirectory if it doesn't exist
        if !FileManager.default.fileExists(atPath: tempDirectory.path) {
            do {
                try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        let filePath = tempDirectory.appendingPathComponent("File." + format)
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try? FileManager.default.removeItem(at: filePath)
            }
        }
        
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            return nil
        }
    }
    
    
    func errorAlert(_ vc: UIViewController, error: APIError, allowsCancel: Bool, retryFunc: @escaping (_ action: UIAlertAction) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.id, message: error.message , preferredStyle: .alert)
            
            alert.view.tintColor = GradeKeeper.themeColor
            
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: retryFunc))
            
            if allowsCancel {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            vc.present(alert, animated: true)
        }
    }
    
    func errorAlert(_ vc: UIViewController, error: APIError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.id, message: error.message , preferredStyle: .alert)
            
            alert.view.tintColor = GradeKeeper.themeColor
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            vc.present(alert, animated: true)
        }
    }
    
    func fieldNotice(_ vc: UIViewController, title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.view.tintColor = GradeKeeper.themeColor
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            vc.present(alert, animated: true)
        }
    }
    
    func actionDialog(_ vc: UIViewController, title: String, message: String, affirmTitle: String, allowsCancel: Bool, retryFunc: @escaping (_ action: UIAlertAction) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
            
            alert.view.tintColor = GradeKeeper.themeColor
            
            alert.addAction(UIAlertAction(title: affirmTitle, style: .default, handler: retryFunc))
            
            if allowsCancel {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            vc.present(alert, animated: true)
        }
    }
    
    func deleteDialog(_ vc: UIViewController, title: String, message: String, allowsCancel: Bool, retryFunc: @escaping (_ action: UIAlertAction) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
            
            alert.view.tintColor = GradeKeeper.themeColor
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: retryFunc))
            
            if allowsCancel {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            vc.present(alert, animated: true)
        }
    }
    
    func tapToDismissKeyboard(_ view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
}
