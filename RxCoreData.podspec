Pod::Spec.new do |s|
    s.name                  = "RxCoreData"
    s.version               = "1.0.1"
    s.summary               = "RxSwift extensions for Core Data"
    s.description           = <<-DESC
    Provides types and extensions for working with Core Data. For example, you can create and hook up a Core Data request to a table view with just a few lines of code:
    ```let fetchRequest = NSFetchRequest(entityName: "User")

    fetchRequest.predicate = NSPredicate(query: "username CONTAINS[cd] %@", searchTerm)

    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]

    managedObjectContext.rx_entities(fetchRequest)
    .bindTo(tableView.rx_itemsWithDataSource(animatedDataSource))
    .addDisposableTo(disposeBag)```
    DESC

    s.homepage              = "https://github.com/RxSwiftCommunity/RxCoreData"
    s.license               = { :type => "MIT", :file => "LICENSE.md" }
    s.authors                = { "Scott Gardner" => "scott.gardner@mac.com",
                                 "RxSwift Community" => "community@rxswift.org"
                                }
    s.source                = { :git => "https://github.com/RxSwiftCommunity/RxCoreData.git",
                                :tag => s.version.to_s
                              }
    s.social_media_url      = "https://twitter.com/scotteg"

    s.ios.deployment_target = '9.3'
    s.osx.deployment_target = '10.12'
    s.watchos.deployment_target = '3.0'
    s.tvos.deployment_target = '9.0'

    s.source_files  = 'Sources/**/*.{swift}'
    s.exclude_files = 'Sources/*.{plist}',  'Sources/**/*.{plist}'
    s.frameworks            = 'CoreData'
    s.swift_version = '5.0'
    s.dependency 'RxSwift', '~> 6.0'
    s.dependency 'RxCocoa', '~> 6.0'
end
