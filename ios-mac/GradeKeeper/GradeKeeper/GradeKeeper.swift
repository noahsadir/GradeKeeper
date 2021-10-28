//
//  GradeKeeper.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 10/27/21.
//

import Foundation


class GradeKeeper {
    var apiKey = "kc9JeeXj1E95ctYqCSTp6k3IPlft3T5f"
    var baseURL = "https://gradekeeper.noahsadir.io/api/"
    var urlSuffix = ""
    
    static var currentUser = User(email: "", password: "", dictionary: [:])
    
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
        ///         pxrint(error.message)
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
            postUnauthenticated(url: apiUrl("create_url"), args: ["api_key": apiKey, "email": email, "password": password]) { (success, result, error) in
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
            self.postUnauthenticated(url: self.apiUrl("authenticate_user"), args: ["api_key": self.apiKey, "email": email, "password": password]) { (success, result, error) in
                if success {
                    GradeKeeper.currentUser = User(email: email, password: password, dictionary: result!)
                }
                callback(success, error)
            }
        }
    }
    
    class category: GradeKeeper {
        
    }
    
    class grade: GradeKeeper {
        
    }
    
    class assignments: GradeKeeper {
        
    }
    
    /// Make a POST request tailored to the GradeKeeper API
    ///
    /// Example of a typical implementation
    /// ```
    /// postUnauthenticated(url: apiUrl("user_create"), args: ["api_key": "DEF456", "email": "user@example.com", "password": "ABC123!"]) { (success, result, error) in
    ///     if success {
    ///         // handle result data
    ///     } else {
    ///         // handle error
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///     - url: The url of the api call. It's recommended to use `apiUrl` rather than hardcode a URL
    ///     - args: The arguments which will be used by the API
    ///     - callback: The closure which is called after the request is completed
    ///     - success: Indicates whether or not request was successful
    ///     - result: The dictionary (JSON) returned by the API call
    ///
    ///        *NOTE:* If the request was unsuccessful, `result == nil`
    ///     - error: Contains the error ID and human-friendly message if the request fails.
    ///
    ///        *NOTE:* If the request was successful, `error == nil`
    func postUnauthenticated(url: URL, args: [String: Any], callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        let json = try? JSONSerialization.data(withJSONObject: args)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            //Get HTTP Response code
            var responseCode = 0
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
            }
            
            //Parse output as JSON or give an error if it fails to do so.
            //Note that API errors will throw a 400 or 500 http code, but will also provide JSON data
            if let data = data {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if responseJSON["success"] as? Bool ?? false {
                        callback(true, responseJSON, nil)
                    } else {
                        callback(false, nil, APIError(dictionary: responseJSON, code: responseCode))
                    }
                } else {
                    callback(false, nil, APIError())
                }
            } else {
                callback(false, nil, APIError(dictionary: ["success": false, "error":"ERR_POST", "message":"Unable to make POST request."], code: responseCode))
            }
        }
        task.resume()
    }
    
    /// Make a POST request with the internal ID and token of the current user.
    /// If the token is expired, the user is automatically re-authentication and another attempt to make the API call is done
    ///
    /// Example of a typical implementation
    /// ```
    /// postAuthenticated(url: apiUrl("list_create"), args: ["name": "Example List", "desciption": "This is an example list!", "private": false]) { (success, result, error) in
    ///     if success {
    ///         // handle result data
    ///     } else {
    ///         // handle error
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///     - url: The url of the api call. It's recommended to use `apiUrl` rather than hardcode a URL
    ///     - args: The arguments which will be used by the API
    ///     - callback: The closure which is called after the request is completed
    ///     - success: Indicates whether or not request was successful
    ///     - result: The dictionary (JSON) returned by the API call
    ///
    ///        *NOTE:* If the request was unsuccessful, `result == nil`
    ///     - error: Contains the error ID and human-friendly message if the request fails.
    ///
    ///        *NOTE:* If the request was successful, `error == nil`
    func postAuthenticated(url: URL, args: [String: Any], callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var newArgs = args
        newArgs["internal_id"] = GradeKeeper.currentUser.internalID
        newArgs["token"] = GradeKeeper.currentUser.tempToken
        
        postUnauthenticated(url: url, args: newArgs) { (success, result, error) in
            if success {
                callback(success, result, error)
            } else if error!.code == 401 {
                //Attempt to re-authenticate
                GradeKeeper.user().authenticate(email: GradeKeeper.currentUser.email, password: GradeKeeper.currentUser.password) { (success, error) in
                    if success {
                        //Make request again with new credentials
                        newArgs["internal_id"] = GradeKeeper.currentUser.internalID
                        newArgs["token"] = GradeKeeper.currentUser.tempToken
                        self.postUnauthenticated(url: url, args: newArgs) { (success, result, error) in
                            callback(success, result, error)
                        }
                    } else {
                        callback(false, nil, APIError(dictionary: ["success": false, "error": "ERR_NOT_AUTH", "message": "The user cannot be re-authenticated."], code: 401))
                    }
                }
            }
        }
        
    }
    
    func apiUrl(_ callType: String) -> URL {
        return URL(string: baseURL + callType + urlSuffix) ?? URL(string: "https://www.example.com")!
    }
}

struct ClassItem {
    var className: String
    var classCode: String
    var color: Int
    var weight: Double
    var categories: [String: Category]
    var gradeScale: [String: Grade]
    
    init(dictionary: [String: Any]) {
        self.className = dictionary["name"] as? String ?? "Unnamed Class"
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

struct Category {
    var name: String
    var dropCount: Int
    var weight: Double
    var assignments: [String]
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["category_name"] as? String ?? "Unnamed Category"
        self.dropCount = dictionary["drop_count"] as? Int ?? 0
        self.weight = dictionary["weight"] as? Double ?? 1
        self.assignments = [String]()
    }
}

struct Grade {
    var minScore: Double
    var maxScore: Double?
    var credit: Double
    
    init(dictionary: [String: Any]) {
        self.minScore = dictionary["min_score"] as? Double ?? 0
        self.maxScore = dictionary["max_score"] as? Double
        self.credit = dictionary["credit"] as? Double ?? 1
    }
}

struct Assignment {
    var title: String
    var description: String
    var gradeID: String
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
        self.gradeID = dictionary["grade_id"] as? String ?? ""
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

struct APIError {
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

struct Gradebook {
    var classes: [String: ClassItem]
    
    init(dictionary: [String: Any]) {
        self.classes = [String: ClassItem]()
        
        if let classItems = dictionary["classes"] as? [String: [String: Any]] {
            for classItem in classItems {
                self.classes[classItem.key] = ClassItem(dictionary: classItem.value)
            }
        }
    }
    
    init() {
        self.classes = [String: ClassItem]()
    }
}

struct User {
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

