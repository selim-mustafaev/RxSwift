//
//  RxNSOutlineViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 16/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

let outlineViewDataSourceNotSet = OutlineViewDataSourceNotSet()

class OutlineViewDataSourceNotSet : NSObject
                                  , NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // This is sometimes called before the datasource is set, as described in the documentation, so we return 0
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        rxAbstractMethod(message: dataSourceNotSet)
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        rxAbstractMethod(message: dataSourceNotSet)
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        rxAbstractMethod(message: dataSourceNotSet)
    }
}

public class RxNSOutlineViewDataSourceProxy : DelegateProxy<NSOutlineView, NSOutlineViewDataSource>
                                            , NSOutlineViewDataSource
                                            , DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var outlineView: NSOutlineView?

    private weak var _requiredMethodsDataSource: NSOutlineViewDataSource? = outlineViewDataSourceNotSet

    /**
     Initializes `RxOutlineViewDataSourceProxy`

     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: NSOutlineView) {
        self.outlineView = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxNSOutlineViewDataSourceProxy.self)
    }

    // MARK: Delegate

    /**
    Required delegate method implementation.
    */
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return ((_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, child: index, ofItem: item))!
    }

    /**
     Required delegate method implementation.
     */
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, isItemExpandable: item) ?? false
    }

    /**
     Required delegate method implementation.
     */
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return (_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, numberOfChildrenOfItem: item) ?? 0
    }

    /**
     Required delegate method implementation.
     */
    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return (_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, objectValueFor: tableColumn, byItem: item)
    }

    // MARK: proxy
    
    public static func registerKnownImplementations() {
        self.register { RxNSOutlineViewDataSourceProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: NSOutlineView) -> NSOutlineViewDataSource? {
        let collectionView: NSOutlineView = castOrFatalError(object)
        return collectionView.dataSource
    }
    
    public static func setCurrentDelegate(_ delegate: NSOutlineViewDataSource?, to object: NSOutlineView) {
        let collectionView: NSOutlineView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }
}
