//
//  AssignmentTableViewController.swift
//  GradeKeeper
//
//  Created by Noah Sadir on 10/28/21.
//

import UIKit

class ViewCourseTableViewController: UITableViewController {
    
    @IBOutlet weak var addAssignmentButton: UIBarButtonItem!
    @IBOutlet weak var classSettingsButton: UIBarButtonItem!
    
    var selectedCourse: Course?
    var categoryIDs = [String]()
    var allCategoryIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.delegate = self
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor
        
        if let course = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            self.title = course.courseName
            self.selectedCourse = course
            self.loadAssignments()
        } else {
            self.removeFromParent()
            print("error retrieving class")
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func loadAssignments() {
        
        categoryIDs = [String]()
        allCategoryIDs = [String]()
        selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID]
        
        // Ensure selected class exists
        if let _ = selectedCourse {
            selectedCourse = GradeKeeper.calculate().sortAssignments(course: selectedCourse!)
            
            // only include categories which contain assignments
            for categoryItem in selectedCourse!.categories {
                
                if categoryItem.value.assignmentIDs.count > 0 {
                    categoryIDs.append(categoryItem.key)
                }
                allCategoryIDs.append(categoryItem.key)
            }
            
            // sort categories
            categoryIDs = categoryIDs.sorted { (first, second) -> Bool in
                if let firstCat = selectedCourse!.categories[first], let secondCat = selectedCourse!.categories[second] {
                    if firstCat.weight != secondCat.weight {
                        return firstCat.weight < secondCat.weight
                    }
                    return firstCat.name < secondCat.name
                }
                return first < second
            }
            
            tableView.reloadData()
        }
        
        /*
        GradeKeeper.assignments().load(courseID: GradeKeeper.selectedCourseID) { (asgSuccess, asgError) in
            GradeKeeper.courses().load() { (grdSuccess, grdError) in
                if asgSuccess && grdSuccess {
                    
                        
                    } else {
                        print("no class selected")
                    }
                } else if let err = asgError {
                    GradeKeeper().errorAlert(self, error: err)
                } else if let err = grdError {
                    GradeKeeper().errorAlert(self, error: err)
                } else {
                    print("unknown error")
                }
            }
        }
         */
    }
        
    @IBAction func addButtonClicked(_ sender: Any) {
        GradeKeeper.selectedAssignmentID = ""
        GradeKeeper.selectedCategoryID = ""
        performSegue(withIdentifier: "createAssignmentSegue", sender: nil)
    }
    
    @IBAction func courseDetailsUnwind(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelEditAssignmentUnwind(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func deleteAssignmentUnwind(unwindSegue: UIStoryboardSegue) {
        if let selectedCourse = selectedCourse {
            loadAssignments()
        }
       
    }
    
    @IBAction func finishEditAssignmentUnwind(unwindSegue: UIStoryboardSegue) {
        if let selectedCourse = selectedCourse {
            loadAssignments()
        }
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categoryIDs.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let selectedCourse = selectedCourse {
            if section == 0 {
                return allCategoryIDs.count + 2
            } else if let category = selectedCourse.categories[categoryIDs[section - 1]] {
                return category.assignmentIDs.count
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Summary"
        } else if let selectedCourse = selectedCourse {
            if let category = selectedCourse.categories[categoryIDs[section - 1]] {
                return category.name
            }
        }
        return ""
    }
    
    func calculateScoreFor(category: Category) -> Double? {
        var assignmentWeight: Double = 0
        var assignmentCredit: Double = 0
        
        for assignmentID in category.assignmentIDs {
            //print(assignmentID)
            if let assignment = GradeKeeper.currentUser.assignments[assignmentID] {
                if let maxScore = GradeKeeper.calculate().adjustedMax(assignment), let actScore = GradeKeeper.calculate().adjustedAct(assignment) {
                    //print(String(actScore) + " / " + String(maxScore))
                    assignmentWeight += maxScore
                    assignmentCredit += actScore
                }
            }
            
        }
        
        let adjustedCredit = (assignmentCredit / assignmentWeight) * category.weight
        if !adjustedCredit.isNormal {
            return nil
        }
        return adjustedCredit
    }
    
    func calculateScoreFor(course: Course) -> [Double] {
        var totalCredit: Double = 0
        var totalWeight: Double = 0
        for category in course.categories {
            if let catScore = calculateScoreFor(category: category.value) {
                totalCredit += catScore
                totalWeight += category.value.weight
            }
        }
        
        return [totalCredit, totalWeight]
    }
    
    func getPercentage(_ numerator: Double, _ denominator: Double) -> String {
        if denominator != 0 {
            return String(format: "%.2f", ((numerator / denominator) * 10000).rounded() / 100) + "%"
        }
        return "--%"
    }
    
    /**/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeholderCell = UITableViewCell()
            
        if let selectedCourse = selectedCourse {
            
            if indexPath.section == 0 {
                
                let summaryCell = tableView.dequeueReusableCell(withIdentifier: "basicRightDetail", for: indexPath) as! UITableViewCell
                
                if indexPath.row == 0 {
                    summaryCell.textLabel?.text = "Grade"
                    var courseScore = calculateScoreFor(course: selectedCourse)
                    if courseScore[1] != 0 {
                        summaryCell.detailTextLabel?.text = GradeKeeper.calculate().grade(adjPercent: (courseScore[0] / courseScore[1]) * 100, gradeScale: selectedCourse.gradeScale)
                    } else {
                        summaryCell.detailTextLabel?.text = ""
                    }
                    
                } else if indexPath.row == 1 {
                    summaryCell.textLabel?.text = "Overall"
                    var courseScore = calculateScoreFor(course: selectedCourse)
                    courseScore[0] = (courseScore[0] * 100).rounded() / 100
                    summaryCell.detailTextLabel?.text = String(courseScore[0]) + " / " + String(courseScore[1]) + " (" + getPercentage(courseScore[0], courseScore[1]) + ")"
                } else {
                    
                    if let category = selectedCourse.categories[allCategoryIDs[indexPath.row - 2]] {
                        summaryCell.textLabel?.text = category.name
                        
                        var catScore = calculateScoreFor(category: category)
                        
                        if let catScore = catScore {
                            summaryCell.detailTextLabel?.text = String((catScore * 100).rounded() / 100) + " / " + String(category.weight) + " (" + getPercentage(catScore, category.weight) + ")"
                        } else {
                            summaryCell.detailTextLabel?.text = "-- / " + String(category.weight)
                        }
                        
                    }
                }
                
                return summaryCell
                
            } else if let category = selectedCourse.categories[categoryIDs[indexPath.section - 1]] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! AssignmentTableViewCell
                if let assignmentItem = GradeKeeper.currentUser.assignments[category.assignmentIDs[indexPath.row]] {
                    if assignmentItem.weight == 0 {
                        cell.assignmentTitle.textColor = .secondaryLabel
                        cell.gradeLabel.textColor = .secondaryLabel
                    } else {
                        cell.assignmentTitle.textColor = .label
                        cell.gradeLabel.textColor = .label
                    }
                    cell.assignmentTitle.text = assignmentItem.title
                    if let actScore = assignmentItem.actScore, let maxScore = assignmentItem.maxScore {
                        if assignmentItem.weight == 0 {
                            cell.rawScoreLabel.text = String(actScore) + " / " + String(maxScore) + " (Dropped)"
                        } else {
                            cell.rawScoreLabel.text = String(actScore) + " / " + String(maxScore) + " (x" + String(assignmentItem.weight) + ")"
                        }
                        cell.gradeLabel.text = String(Int((actScore / maxScore) * 100)) + "%"
                    } else {
                        cell.rawScoreLabel.text = "Awaiting score"
                        cell.gradeLabel.text = "-- %"
                    }
                    
                    if let dueDateSecs = assignmentItem.dueDate {
                        let dueDate = Date(timeIntervalSince1970: TimeInterval(dueDateSecs))
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MMM dd, yyyy h:mm a"
                        
                        cell.dueDateLabel.text = dateFormatterPrint.string(from: dueDate)
                    } else {
                        cell.dueDateLabel.text = "(No due date)"
                    }
                } else {
                    print("asg error")
                }
                return cell
            } else {
                print("cat error")
            }
        } else {
            print("cla error")
        }
        
        // Configure the cell...

        return placeholderCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 45
        }
        
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            if let selectedCourse = selectedCourse {
                if let category = selectedCourse.categories[categoryIDs[indexPath.section - 1]] {
                    GradeKeeper.selectedAssignmentID = category.assignmentIDs[indexPath.row]
                    GradeKeeper.selectedCategoryID = categoryIDs[indexPath.section - 1]
                    performSegue(withIdentifier: "showAssignmentSegue", sender: nil)
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
            
            
        }
    }
    /**/

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
