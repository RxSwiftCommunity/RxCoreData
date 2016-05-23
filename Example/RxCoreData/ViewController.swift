//
//  ViewController.swift
//  RxCoreData
//
//  Created by Scott Gardner on 05/18/2016.
//  Copyright (c) 2016 Scott Gardner. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    let searchText = Variable("")
    var managedObjectContext: NSManagedObjectContext!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        configureTableView()
    }
    
    func bindUI() {
        addBarButtonItem.rx_tap
            .map { _ in
                Event(id: NSUUID().UUIDString, date: NSDate())
            }
            .subscribeNext { [unowned self] event in
                _ = try? self.managedObjectContext.update(event)
            }
            .addDisposableTo(disposeBag)
    }
    
    func configureTableView() {
        tableView.editing = true
        
        /*
         // Non-animated
         managedObjectContext.rx_entities(Event.self, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
         .bindTo(tableView.rx_itemsWithCellIdentifier("Cell")) { row, event, cell in
         cell.textLabel?.text = "\(event.date)"
         }
         .addDisposableTo(disposeBag)
         */
        
        // Animated
        let animatedDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Event>>()
        animatedDataSource.configureCell = { dateSource, tableView, indexPath, event in
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel?.text = "\(event.date)"
            return cell
        }
        
        managedObjectContext.rx_entities(Event.self, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
            .map { events in
                [AnimatableSectionModel(model: "Section 1", items: events)]
            }
            .bindTo(tableView.rx_itemsWithDataSource(animatedDataSource))
            .addDisposableTo(disposeBag)
        
        self.tableView.rx_itemDeleted
            .map { [unowned self] indexPath in
                try self.tableView.rx_modelAtIndexPath(indexPath) as Event
            }
            .subscribeNext { [unowned self] deletedEvent in
                _ = try? self.managedObjectContext.delete(deletedEvent)
            }
            .addDisposableTo(disposeBag)
    }
}
