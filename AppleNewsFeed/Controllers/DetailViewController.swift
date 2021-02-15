//
//  DetailViewController.swift
//  AppleNewsFeed
//
//  Created by Elīna Zekunde on 12/02/2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    var savedItems = [Items]()
    var context: NSManagedObjectContext?
    
    var webURLString = String()
    var titleString = String()
    var contentString = String()
    var newsImage: UIImage?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var newsImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Apple"
        
        titleLabel.text = titleString
        contentTextView.text = contentString
        newsImageView.image = newsImage
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func savedButtonTapped(_ sender: Any) {
        let newItem = Items(context: self.context!)
        newItem.newsTitle = titleString
        newItem.newsContent = contentString
        newItem.url = webURLString
        
        guard let imageData: Data = (newsImage?.pngData()) else { return }
        
        if !imageData.isEmpty {
            newItem.image = imageData
        }
        
        self.savedItems.append(newItem)
        saveData()
        
        warningPopup(withTitle: "Saved!", withMessage: nil)
    }
    
    func warningPopup(withTitle title: String?, withMessage message: String?) {
        DispatchQueue.main.async {
            let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            popup.addAction(okButton)
            
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    func saveData() {
        do {
            try context?.save()
        } catch {
            warningPopup(withTitle: "Error!", withMessage: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destination: WebViewController = segue.destination as! WebViewController
        // Pass the selected object to the new view controller.
        destination.urlString = webURLString
    }
    
}
