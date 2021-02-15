//
//  SavedNewsTableViewController.swift
//  AppleNewsFeed
//
//  Created by Elīna Zekunde on 15/02/2021.
//

import UIKit
import CoreData

class SavedNewsTableViewController: UITableViewController {
    
    var savedItems = [Items]()
    var context: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        
        do {
            savedItems = try (context?.fetch(request))!
        } catch {
            warningPopup(withTitle: "Error!", withMessage: error.localizedDescription)
        }
    }

    func saveData() {
        do {
            try context?.save()
        } catch {
            warningPopup(withTitle: "Error!", withMessage: error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    func warningPopup(withTitle title: String?, withMessage message: String?) {
        DispatchQueue.main.async {
            let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            popup.addAction(okButton)
            
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return savedItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedFeedCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let item = savedItems[indexPath.row]

        if item.image != nil {
            if let image = UIImage(data: item.image!) {
                cell.newsImageView.image = image
            }
        } else {
            cell.newsImageView.image = nil
        }
        
        cell.newsTitleLabel.text = item.newsTitle
        cell.newsTitleLabel.numberOfLines = 0
        
        return cell
    }

    // MARK: - Table view Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let alert = UIAlertController(title: "Delete", message: "Are you sure to delete?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let item = self.savedItems[indexPath.row]
                
                self.context?.delete(item)
                self.saveData()
            }))
            self.present(alert, animated: true)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let currentItem = savedItems.remove(at: fromIndexPath.row)
        savedItems.insert(currentItem, at: to.row)
        saveData()
    }

    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let vc = storyboard.instantiateViewController(identifier: "WebViewController") as? WebViewController else {
            return
        }
        
        vc.urlString = savedItems[indexPath.row].url!
            
        navigationController?.pushViewController(vc, animated: true)
    }
}
