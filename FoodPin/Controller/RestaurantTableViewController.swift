//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Vitalina Spinu on 26.10.2022.
//

import UIKit
import CoreData
import UserNotifications

class RestaurantTableViewController: UITableViewController {
    
    @IBOutlet var emptyRestaurantView: UIView!
    
    var restaurants: [Restaurant] = []
    var fetchResultController: NSFetchedResultsController<Restaurant>!
    var searchController: UISearchController!
    
    lazy var dataSource = configureDataSource()
    
    // MARK: - View controller life cycle”
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            navigationController?.hidesBarsOnSwipe = true
            navigationItem.backButtonTitle = ""
            navigationController?.navigationBar.prefersLargeTitles = true
        
            tableView.separatorStyle = .none
            tableView.dataSource = dataSource
            tableView.cellLayoutMarginsFollowReadableWidth = true
        
        if let appearance = navigationController?.navigationBar.standardAppearance {

            appearance.configureWithTransparentBackground()

            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {

                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        // Prepare the empty view
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
        
        fetchRestaurantData()
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search restaurants..."
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor(named: "NavigationBarTitle")
        
        prepareNotification()
        
    }
    // MARK: - UITableView Diffable Data Source”

     func configureDataSource() -> RestaurantDiffableDataSource {

        let cellIdentifier = "detacell"

        let dataSource = RestaurantDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, restaurant in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell

                cell.nameLabel.text = restaurant.name
                cell.typeLabel.text = restaurant.type
                cell.locationLabel.text = restaurant.location
                cell.thumbnailImageView.image = UIImage(data: restaurant.image)
                cell.favoriteImageView.isHidden = restaurant.isFavorite ? false : true
                
                
                return cell
            }
        )

        return dataSource
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
         if searchController.isActive {
                return UISwipeActionsConfiguration()
            }
        
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else {
            return UISwipeActionsConfiguration()
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in

            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext

                    // Delete the item
                    context.delete(restaurant)
                    appDelegate.saveContext()

                    // Update the view
                    self.updateSnapshot(animatingChange: true)
                }

                // Call completion handler to dismiss the action button
                completionHandler(true)
            
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let defaultText = "Just checking in at " + restaurant.name
            let activityController: UIActivityViewController
            if let imageToShare = UIImage(data: restaurant.image) {
                
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
                completionHandler(true)

            }
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")

        shareAction.backgroundColor = UIColor.systemOrange
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])

            return swipeConfiguration
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favAction = UIContextualAction(style: .destructive, title: "") { (action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell

            cell.favoriteImageView.isHidden = self.restaurants[indexPath.row].isFavorite
            
            self.restaurants[indexPath.row].isFavorite = self.restaurants[indexPath.row].isFavorite ? false : true
            
            completionHandler(true)
        }
    
        favAction.backgroundColor = UIColor.systemYellow
        favAction.image = UIImage(systemName: self.restaurants[indexPath.row].isFavorite ? "heart.slash.fill" : "heart.fill")
    
    let swipeConfiguration = UISwipeActionsConfiguration(actions: [favAction])

        return swipeConfiguration
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = self.restaurants[indexPath.row]
                destinationController.hidesBottomBarWhenPushed = true            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    

    func fetchRestaurantData(searchText: String = "") {
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
            
            }
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self

            do {
                try fetchResultController.performFetch()
                updateSnapshot(animatingChange: searchText.isEmpty ? false : true)
            } catch {
                print(error)
            }
        }
    }
func updateSnapshot(animatingChange: Bool = false) {

    if let fetchedObjects = fetchResultController.fetchedObjects {
        restaurants = fetchedObjects
    }
    var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
    snapshot.appendSections([.all])
    snapshot.appendItems(restaurants, toSection: .all)
    
       dataSource.apply(snapshot, animatingDifferences: animatingChange)
    
       tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
}
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
                return
            }
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {

            present(walkthroughViewController, animated: true, completion: nil)
        }
    }
   
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        // Get the selected restaurant
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let configuration = UIContextMenuConfiguration(identifier: indexPath.row as NSCopying, previewProvider: {

            guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController
            else {
                return nil
            }
            restaurantDetailViewController.restaurant = restaurant

                    return restaurantDetailViewController

                }) { actions in

                    let favoriteAction = UIAction(title: "Save as favorite", image: UIImage(systemName: "heart")) { action in

                        let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
                        self.restaurants[indexPath.row].isFavorite.toggle()
                        cell.favoriteImageView.isHidden = !self.restaurants[indexPath.row].isFavorite
                    }

                    let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in

                        let defaultText = NSLocalizedString("Just checking in at ", comment: "Just checking in at") + self.restaurants[indexPath.row].name
                        let activityController: UIActivityViewController

                                    if let imageToShare = UIImage(data: restaurant.image as Data) {
                                        activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
                                    } else  {
                                        activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
                                    }

                                    self.present(activityController, animated: true, completion: nil)
                                }

                                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in

                                    // Delete the row from the data store
                                    if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                                        let context = appDelegate.persistentContainer.viewContext
                                        let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                                    context.delete(restaurantToDelete)

                                                        appDelegate.saveContext()
                                                    }
                                                }

                                                // Create and return a UIMenu with the share action
                                                return UIMenu(title: "", children: [favoriteAction, shareAction, deleteAction])
                                            }

                                            return configuration
                                        }
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {

        guard let selectedRow = configuration.identifier as? Int else {
            print("Failed to retrieve the row number")
            return
        }

        guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController else {
                 return
                }

                restaurantDetailViewController.restaurant = self.restaurants[selectedRow]

                animator.preferredCommitStyle = .pop
                animator.addCompletion {
                    self.show(restaurantDetailViewController, sender: self)
                }
            }
    func prepareNotification() {
        // Make sure the restaurant array is not empty
        if restaurants.count <= 0 {
            return
        }
        
        // Pick a restaurant randomly
        let randomNum = Int.random(in: 0..<restaurants.count)
        let suggestedRestaurant = restaurants[randomNum]

        // Create the user notification
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recommend you to check out \(suggestedRestaurant.name). The restaurant is one of your favorites. It is located at \(suggestedRestaurant.location). Would you like to give it a try?"
        content.sound = UNNotificationSound.default
        content.userInfo = ["phone": suggestedRestaurant.phone]
        
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")

        if let image = UIImage(data: suggestedRestaurant.image as Data) {

            try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
                content.attachments = [restaurantImage]
            }
        }
        let categoryIdentifer = "foodpin.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "foodpin.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "foodpin.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifer, actions: [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifer
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "foodpin.restaurantSuggestion", content: content, trigger: trigger)
        
        // Schedule the notification
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        }
    
}
    
    extension RestaurantTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            updateSnapshot()
        }
    
}
extension RestaurantTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        guard let searchText = searchController.searchBar.text else {
            return
        }

        fetchRestaurantData(searchText: searchText)
    }
}
