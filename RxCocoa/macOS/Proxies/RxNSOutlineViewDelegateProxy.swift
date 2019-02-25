//
//  RxNSOutlineViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 16/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

public class RxNSOutlineViewDelegateProxy : DelegateProxy<NSOutlineView, NSOutlineViewDelegate>
        , NSOutlineViewDelegate
, DelegateProxyType {
    
    /**
     Typed parent object.
     */
    public weak private(set) var outlineView: NSOutlineView?

    public required init(parentObject: NSOutlineView) {
        self.outlineView = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxNSOutlineViewDelegateProxy.self)
    }

    // MARK : Delegate Proxy

    public static func registerKnownImplementations() {
        self.register { RxNSOutlineViewDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: NSOutlineView) -> NSOutlineViewDelegate? {
        let outlineView: NSOutlineView = castOrFatalError(object)
        return outlineView.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: NSOutlineViewDelegate?, to object: NSOutlineView) {
        let outlineView: NSOutlineView = castOrFatalError(object)
        outlineView.delegate = castOptionalOrFatalError(delegate)
    }
}
