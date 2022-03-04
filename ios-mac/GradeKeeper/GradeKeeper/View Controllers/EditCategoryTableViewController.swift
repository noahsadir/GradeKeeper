//  EditCategoryTableViewController.swift
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

import UIKit

class EditCategoryTableViewController: UITableViewController {

    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var categoryWeightTextField: UITextField!
    @IBOutlet weak var assignmentsDroppedTextField: UITextField!
    @IBOutlet weak var deleteCategoryButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = GradeKeeper.themeColor
        self.navigationController?.navigationBar.tintColor = GradeKeeper.themeColor

        if let selectedCourse = GradeKeeper.currentUser.courses[GradeKeeper.selectedCourseID] {
            if let selectedCategory = selectedCourse.categories[ViewCategoriesTableViewController.selectedCategoryID ?? ""] {
                self.title = "Edit Category"
                
                categoryNameTextField.text = selectedCategory.name
                categoryWeightTextField.text = String(selectedCategory.weight)
                assignmentsDroppedTextField.text = String(selectedCategory.dropCount)
                
            } else {
                self.title = "New Category"
                deleteCategoryButton.isEnabled = false
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func deleteCategoryButtonClicked(_ sender: Any) {
        if let categoryID = ViewCategoriesTableViewController.selectedCategoryID {
            GradeKeeper().deleteDialog(self, title: "Delete Category", message: "Are you sure you want to delete this category?", allowsCancel: true) { (action) in
                GradeKeeper.category().delete(courseID: GradeKeeper.selectedCourseID, categoryID: categoryID) { (success, error) in
                    DispatchQueue.main.async {
                        if success {
                            self.performSegue(withIdentifier: "finishCategoryEdit", sender: self)
                        } else {
                            GradeKeeper().errorAlert(self, error: error!)
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func editCategoryButtonClicked(_ sender: Any) {
        var categoryName: String?
        var weight: Double?
        var dropCount: Int?
        
        categoryName = categoryNameTextField.text ?? ""
        if categoryName == "" {
            categoryName = nil
        }
        
        if let weightString = categoryWeightTextField.text {
            weight = Double(weightString)
        }
        
        if let dropString = assignmentsDroppedTextField.text {
            dropCount = Int(dropString)
        }
        
        if categoryName != nil {
            if weight != nil {
                if dropCount != nil {
                    if ViewCategoriesTableViewController.selectedCategoryID == nil {
                        GradeKeeper.category().create(courseID: GradeKeeper.selectedCourseID, categoryName: categoryName!, weight: weight!, dropCount: dropCount!) { (success, error) in
                            if success {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "finishCategoryEdit", sender: nil)
                                }
                            } else {
                                GradeKeeper().errorAlert(self, error: error!)
                            }
                        }
                    } else {
                        GradeKeeper.category().modify(courseID: GradeKeeper.selectedCourseID, categoryID: ViewCategoriesTableViewController.selectedCategoryID!, categoryName: categoryName!, weight: weight!, dropCount: dropCount!) { (success, error) in
                            if success {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "finishCategoryEdit", sender: nil)
                                }
                            } else {
                                GradeKeeper().errorAlert(self, error: error!)
                            }
                        }
                    }
                } else {
                    GradeKeeper().fieldNotice(self, title: "Invalid Drop Count", message: "Please enter a valid number for assignments dropped.")
                }
            } else {
                GradeKeeper().fieldNotice(self, title: "Invalid Weight", message: "Please enter a valid number for category weight.")
            }
        } else {
            GradeKeeper().fieldNotice(self, title: "Invalid Category Name", message: "Please enter a valid name for the category.")
        }
        
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
