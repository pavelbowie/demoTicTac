//
//  LeaderboardTableViewController.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import CoreData
import UIKit

class LeaderboardTableViewController: UITableViewController {
    
    fileprivate lazy var fetchRequest: NSFetchRequest<Leaderboard> = {
        let fetchRequest = NSFetchRequest<Leaderboard>(entityName:String(describing:Leaderboard.self))
        let descriptor = NSSortDescriptor(key: "position", ascending: true)
        fetchRequest.sortDescriptors = [descriptor]
        return fetchRequest
    }()
    
    lazy var fetchResultsController: NSFetchedResultsController<Leaderboard> = {
        let context = CoreDataStack.sharedDataStack.mainQueueManagedObjectContext
        
        let resultsController = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        resultsController.delegate = self
        try? resultsController.performFetch()
        return resultsController
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Leaderboard"
        return label
    } ()

    let leaderboardClient = BackendServerClient()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleLabel
        self.navigationController?.navigationBar.barTintColor = .black
        leaderboardClient.getLeaderboardScore { _,_ in
            self.tableView.reloadData()
        }
    }
  
    @IBAction func closeLeaderboardButtonHandler(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension LeaderboardTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let countGames = self.fetchResultsController.fetchedObjects?.count ?? 0
        return countGames
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:LeaderboardCell.self), for: indexPath)
        if let cell = cell as? LeaderboardCell,let score = self.fetchResultsController.fetchedObjects?[indexPath.row] {
            let viewModel = LeaderboardViewModel(with: score)
            cell.configure(with: viewModel)
        }
        return cell
    }
}


extension LeaderboardTableViewController: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath ,let newIndexPath = newIndexPath {
                self.tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        case .update:
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
