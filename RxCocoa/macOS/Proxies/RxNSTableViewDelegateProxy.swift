//
//  RxNSTableViewDelegateProxy.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//


import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

public class RxNSTableViewDelegateProxy : DelegateProxy<NSTableView, NSTableViewDelegate>
                                        , NSTableViewDelegate
, DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var tableView: NSTableView?
    
    public required init(parentObject: NSTableView) {
        self.tableView = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxNSTableViewDelegateProxy.self)
    }
    
    // MARK : Delegate Proxy
    
    public static func registerKnownImplementations() {
        self.register { RxNSTableViewDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: NSTableView) -> NSTableViewDelegate? {
        let tableView: NSTableView = castOrFatalError(object)
        return tableView.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: NSTableViewDelegate?, to object: NSTableView) {
        let tableView: NSTableView = castOrFatalError(object)
        tableView.delegate = castOptionalOrFatalError(delegate)
    }
}
