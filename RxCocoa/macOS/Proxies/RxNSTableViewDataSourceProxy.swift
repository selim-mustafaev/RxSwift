//
//  RxNSTableViewDataSourceProxy.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet : NSObject
                                , NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        // This is sometimes called before the datasource is set, as described in the documentation, so we return 0
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        rxAbstractMethod(message: dataSourceNotSet)
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        rxAbstractMethod(message: dataSourceNotSet)
    }
}

public class RxNSTableViewDataSourceProxy : DelegateProxy<NSTableView, NSTableViewDataSource>
                                          , NSTableViewDataSource
, DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var tableView: NSTableView?
    
    private weak var _requiredMethodsDataSource: NSTableViewDataSource? = tableViewDataSourceNotSet
    
    /**
     Initializes `RxTableViewDataSourceProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: NSTableView) {
        self.tableView = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxNSTableViewDataSourceProxy.self)
    }
    
    // MARK: Delegate
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).numberOfRows?(in: tableView) ?? 0
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView?(tableView, objectValueFor: tableColumn, row: row)
    }
    
    public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView?(tableView, setObjectValue: object, for: tableColumn, row: row)
    }
    
    // MARK: proxy
    
    public static func registerKnownImplementations() {
        self.register { RxNSTableViewDataSourceProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: NSTableView) -> NSTableViewDataSource? {
        let collectionView: NSTableView = castOrFatalError(object)
        return collectionView.dataSource
    }
    
    public static func setCurrentDelegate(_ delegate: NSTableViewDataSource?, to object: NSTableView) {
        let collectionView: NSTableView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }
}
