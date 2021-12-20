//
//  GradeKeeper.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 10/27/21.
//

import Foundation
import UIKit


class GradeKeeper {
    
    var baseURL = "https://gradekeeper.noahsadir.io/api/"
    var urlSuffix = ""
    
    
    static var currentUser = User()
    static var selectedCourseID = ""
    static var selectedAssignmentID = ""
    static var selectedCategoryID = ""
    static var themeColor = UIColor.systemPurple
    
    class user: GradeKeeper {
        
        /// Create a new user
        ///
        /// Example of a typical implementation
        /// ```
        /// GradeKeeper.user().create(email: "name@example.com", password: "Abc123!") { (success, error) in
        ///     if (success) {
        ///         // handle success
        ///     } else {
        ///         print(error.id)
        ///         print(error.message)
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
        ///         print(error.id)
        ///         print(error.message)
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
        ///         print(error.id)
        ///         print(error.message)
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
        
    }
    
    class assignments: GradeKeeper {
        
        func load(courseID: String, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                callback(true, nil)
            } else {
                GKCalls().getAssignments(&GradeKeeper.currentUser, courseID: courseID, ignoreBeforeDate: nil) { (success, result, error) in
                    if success {
                        if let assignments = result!["assignments"] as? [String: [String: Any]] {
                            GradeKeeper.currentUser.assignments = [String: Assignment]()
                            for assignmentItem in assignments {
                                GradeKeeper.currentUser.assignments[assignmentItem.key] = Assignment(dictionary: assignmentItem.value)
                            }
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
                        GradeKeeper.assignments().load(courseID: courseID) { (asgSuccess, asgErr) in
                            callback(asgSuccess, asgErr)
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
    }
    
    class courses: GradeKeeper {
        
        func load(callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                callback(true, nil)
            } else {
                GKCalls().getCourses(&GradeKeeper.currentUser) { (success, result, error) in
                    if success {
                        if let gradebook = result!["gradebook"] as? [String: Any] {
                            GradeKeeper.currentUser.courses = GradeKeeper.currentUser.configClasses(dictionary: gradebook)
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
        
        func create(courseName: String, courseCode: String?, color: Int?, weight: Double?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                let courseID = "localcrs_" + String(Date().timeIntervalSince1970);
                if let _ = GradeKeeper.currentUser.courses[courseID] {
                    callback(false, APIError(id: "LOC_ERR_COURSE_EXISTS", message: "The course already exists.", code: 400))
                } else {
                    GradeKeeper.currentUser.courses[courseID] = Course(courseName: courseName, courseCode: courseCode, color: color, weight: weight)
                    callback(true, nil)
                }
                
            } else {
                GKCalls().createCourse(&GradeKeeper.currentUser, courseName: courseName, courseCode: courseCode, color: color, weight: weight) { (success, result, error) in
                    callback(success, error)
                }
            }
        }
        
        func modify(courseID: String, courseName: String, courseCode: String, color: Int?, weight: Double?, callback: @escaping (_ success: Bool, _ error: APIError?) -> Void) {
            if GradeKeeper.currentUser.isLocal {
                if let _ = GradeKeeper.currentUser.courses[courseID] {
                    GradeKeeper.currentUser.courses[courseID] = Course(courseName: courseName, courseCode: courseCode, color: color, weight: weight)
                    callback(true, nil)
                } else {
                    callback(false, APIError(id: "LOC_ERR_INVALID_COURSE", message: "The specified course does not exist.", code: 400))
                }
            } else {
                GKCalls().modifyCourse(&GradeKeeper.currentUser, courseID: courseID, courseName: courseName, courseCode: courseCode, color: color, weight: weight) { (success, result, error) in
                    callback(success, error)
                }
            }
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
        
        func sortAssignments(course: Course) -> Course {
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
        
        func sortCategories(course: Course) -> [String] {
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
    
    class storage: GradeKeeper {
        
        class user: storage {
            func save() {
                
            }
            
            func load() {
                
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
    }
    
    func userToJSON() {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(GradeKeeper.currentUser)
        if let jsonData = jsonData {
            print(String(data: jsonData, encoding: .utf8))
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
    
}
