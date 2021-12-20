//
//  GKCalls.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 12/18/21.
//
//  PURPOSE: Provides near-direct Swift bindings to all relevant API calls.
//

import Foundation

class GKCalls {
    
    var baseURL = "https://gradekeeper.noahsadir.io/api/"
    var apiKey = "kc9JeeXj1E95ctYqCSTp6k3IPlft3T5f"
    var urlSuffix = ""
    var token = ""
    
    public func createUser(email: String, password: String, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["api_key"] = apiKey
        args["email"] = email
        args["password"] = password
        
        postUnauthenticated(url: apiUrl("create_user"), args: args, callback: callback)
    }
    
    public func authenticateUser(email: String, password: String, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["api_key"] = apiKey
        args["email"] = email
        args["password"] = password
        
        postUnauthenticated(url: apiUrl("authenticate_user"), args: args, callback: callback)
    }
    
    public func createAssignment(_ user: UnsafeMutablePointer<User>, courseID: String, categoryID: String, title: String?, description: String?, gradeID: String?, actScore: Double?, maxScore: Double?, weight: Double?, penalty: Double?, dueDate: UInt64?, assignDate: UInt64?, gradedDate: UInt64?, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["category_id"] = categoryID
        args["title"] = title
        args["description"] = description
        args["grade_id"] = gradeID
        args["act_score"] = actScore
        args["max_score"] = maxScore
        args["weight"] = weight
        args["penalty"] = penalty
        args["due_date"] = dueDate
        args["assign_date"] = assignDate
        args["graded_date"] = gradedDate
        
        postAuthenticated(user, url: apiUrl("create_assignment"), args: args, callback: callback)
    }
    
    public func createCategory(_ user: UnsafeMutablePointer<User>, courseID: String, categoryName: String, dropCount: Int?, weight: Double?, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["category_name"] = categoryName
        args["drop_count"] = dropCount
        args["weight"] = weight
        
        postAuthenticated(user, url: apiUrl("create_category"), args: args, callback: callback)
    }
    
    public func createCourse(_ user: UnsafeMutablePointer<User>, courseName: String, courseCode: String?, color: Int?, weight: Double?,  callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_name"] = courseName
        args["class_code"] = courseCode
        args["color"] = color
        args["weight"] = weight
        
        postAuthenticated(user, url: apiUrl("create_class"), args: args, callback: callback)
    }
    
    public func createGrade(_ user: UnsafeMutablePointer<User>, courseID: String, gradeID: String, minScore: Double, maxScore: Double?, credit: Double, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["grade_id"] = gradeID
        args["min_score"] = minScore
        args["max_score"] = maxScore
        args["credit"] = credit
        
        postAuthenticated(user, url: apiUrl("create_grade"), args: args, callback: callback)
    }
    
    public func modifyAssignment(_ user: UnsafeMutablePointer<User>, courseID: String, categoryID: String, assignmentID: String, title: String?, description: String?, gradeID: String?, actScore: Double?, maxScore: Double?, weight: Double?, penalty: Double?, dueDate: UInt64?, assignDate: UInt64?, gradedDate: UInt64?, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["category_id"] = categoryID
        args["assignment_id"] = assignmentID
        args["title"] = title
        args["description"] = description
        args["grade_id"] = gradeID
        args["act_score"] = actScore
        args["max_score"] = maxScore
        args["weight"] = weight
        args["penalty"] = penalty
        args["due_date"] = dueDate
        args["assign_date"] = assignDate
        args["graded_date"] = gradedDate
        
        postAuthenticated(user, url: apiUrl("modify_assignment"), args: args, callback: callback)
    }
    
    public func modifyCategory(_ user: UnsafeMutablePointer<User>, courseID: String, categoryID: String, categoryName: String, dropCount: Int?, weight: Double?, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["category_id"] = categoryID
        args["category_name"] = categoryName
        args["drop_count"] = dropCount
        args["weight"] = weight
        
        postAuthenticated(user, url: apiUrl("modify_category"), args: args, callback: callback)
    }
    
    public func modifyCourse(_ user: UnsafeMutablePointer<User>, courseID: String, courseName: String, courseCode: String?, color: Int?, weight: Double?,  callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["class_name"] = courseName
        args["class_code"] = courseCode
        args["color"] = color
        args["weight"] = weight
        
        postAuthenticated(user, url: apiUrl("modify_class"), args: args, callback: callback)
    }
    
    public func modifyGrade(_ user: UnsafeMutablePointer<User>, courseID: String, gradeID: String, minScore: Double, maxScore: Double?, credit: Double, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["grade_id"] = gradeID
        args["min_score"] = minScore
        args["max_score"] = maxScore
        args["credit"] = credit
        
        postAuthenticated(user, url: apiUrl("modify_grade"), args: args, callback: callback)
    }
    
    public func deleteAssignment(_ user: UnsafeMutablePointer<User>, courseID: String, assignmentID: String, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["assignment_id"] = assignmentID
        
        postAuthenticated(user, url: apiUrl("delete_assignment"), args: args, callback: callback)
    }
    
    public func deleteCategory(_ user: UnsafeMutablePointer<User>, courseID: String, categoryID: String, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["category_id"] = categoryID
        
        postAuthenticated(user, url: apiUrl("delete_category"), args: args, callback: callback)
    }
    
    public func getAssignments(_ user: UnsafeMutablePointer<User>, courseID: String, ignoreBeforeDate: UInt64?, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var args = [String: Any]()
        args["class_id"] = courseID
        args["ignore_before_date"] = ignoreBeforeDate
        
        postAuthenticated(user, url: apiUrl("get_assignments"), args: args, callback: callback)
    }
    
    public func getCourses(_ user: UnsafeMutablePointer<User>, callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        let args = [String: Any]()
        
        postAuthenticated(user, url: apiUrl("get_classes"), args: args, callback: callback)
    }
    
    private func apiUrl(_ callType: String) -> URL {
        return URL(string: baseURL + callType + urlSuffix) ?? URL(string: "https://www.example.com")!
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
    private func postUnauthenticated(url: URL, args: [String: Any], callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
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
                        let resultErr = APIError(dictionary: responseJSON, code: responseCode)
                        if resultErr.id.hasPrefix("DBG") {
                            print("A DEBUGGABLE ERROR HAS OCCURRED")
                            print(responseJSON["details"] as Any)
                        }
                        callback(false, nil, resultErr)
                        
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
    /// postAuthenticated(user, url: apiUrl("list_create"), args: ["name": "Example List", "desciption": "This is an example list!", "private": false]) { (success, result, error) in
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
    private func postAuthenticated(_ currentUser:UnsafeMutablePointer<User>, url: URL, args: [String: Any], callback: @escaping (_ success: Bool, _ result: [String: Any]?, _ error: APIError?) -> Void) {
        
        var newArgs = args
        newArgs["internal_id"] = currentUser.pointee.internalID
        newArgs["token"] = currentUser.pointee.tempToken
        
        postUnauthenticated(url: url, args: newArgs) { (success, result, error) in
            
            if success {
                callback(success, result, error)
            } else if error!.code == 401 {
                //Attempt to re-authenticate
                
                self.authenticateUser(email: currentUser.pointee.email, password: currentUser.pointee.password) { (success, result, error) in
                    if success {
                        currentUser.pointee.internalID = result!["internal_id"] as? String ?? ""
                        currentUser.pointee.tempToken = result!["token"] as? String ?? ""
                        //Make request again with new credentials
                        newArgs["internal_id"] = currentUser.pointee.internalID
                        newArgs["token"] = currentUser.pointee.tempToken
                        self.postUnauthenticated(url: url, args: newArgs) { (success, result, error) in
                            callback(success, result, error)
                        }
                    } else {
                        callback(false, nil, APIError(dictionary: ["success": false, "error": "ERR_NOT_AUTH", "message": "The user cannot be re-authenticated."], code: 401))
                    }
                }
            } else {
                callback(false, nil, error!)
            }
        }
        
    }
}
