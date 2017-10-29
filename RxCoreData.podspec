Pod::Spec.new do |s|
    s.name                  = "RxCoreData"
    s.version               = "0.4.0"
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
    s.author                = { "Scott Gardner" => "scott.gardner@mac.com" }
    s.source                = { :git => "https://github.com/RxSwiftCommunity/RxCoreData.git", :tag => s.version.to_s }
    s.social_media_url      = "https://twitter.com/scotteg"

    s.ios.deployment_target = '8.0'

    s.source_files = 'Sources/**/*'

    s.frameworks            = 'UIKit', 'CoreData'

    s.dependency 'RxSwift', '~> 4.0'
    s.dependency 'RxCocoa', '~> 4.0'
end
