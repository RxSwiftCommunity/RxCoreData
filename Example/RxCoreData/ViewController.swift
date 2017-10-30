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
    
    var managedObjectContext: NSManagedObjectContext!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        configureTableView()
    }
    
    func bindUI() {
        addBarButtonItem.rx.tap
            .map { _ in
                Event(id: UUID().uuidString, date: Date())
            }.subscribe(onNext: { [weak self] (event) in
                _ = try? self?.managedObjectContext.rx.update(event)
            })
            .disposed(by: disposeBag)
    }
    
    func configureTableView() {
        tableView.isEditing = true
        
        /*
         // Non-animated
        
         managedObjectContext.rx.entities(Event.self,
                                          sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
            .bindTo(tableView.rx.items(cellIdentifier: "Cell")) { row, event, cell in
                cell.textLabel?.text = "\(event.date)"
            }
            .addDisposableTo(disposeBag)
        */
        
        // Animated

        let animatedDataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Event>>(configureCell: { dateSource, tableView, indexPath, event in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "\(event.date)"
            return cell
        })
        
        managedObjectContext.rx.entities(Event.self, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
            .map { events in
                [AnimatableSectionModel(model: "Section 1", items: events)]
            }
            .bind(to: tableView.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
 
        self.tableView.rx.itemDeleted.map { [unowned self] ip -> Event in
            return try self.tableView.rx.model(at: ip)
            }
            .subscribe(onNext: { [unowned self] (event) in
                do {
                    try self.managedObjectContext.rx.delete(event)
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)
        
        animatedDataSource.canEditRowAtIndexPath = { _,_  in
            return true
        }
        animatedDataSource.canMoveRowAtIndexPath = { _,_  in
            return true
        }
    }
}
