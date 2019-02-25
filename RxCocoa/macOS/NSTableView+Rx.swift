//
//  NSTableView+Rx.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSTableView {
    
    /**
     Binds sequences of elements to table view rows.
     
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    
    public func rx_items<E: NSObject, S: Sequence, O: ObservableType>
        (source: O) -> Disposable where S.Iterator.Element == Dictionary</*String*/NSUserInterfaceItemIdentifier, E>, O.E == S {
            let dataSource = RxNSTableViewReactiveArrayDataSourceSequenceWrapper<E, S>()
            
        return rx_itemsWithTableViewDataSource(dataSource: dataSource, source: source)
    }
    
    /**
     Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
     
     - parameter dataSource: Data source
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    public func rx_itemsWithTableViewDataSource<DataSource: RxNSTableViewDataSourceType & NSTableViewDataSource, S: Sequence, O: ObservableType>
        (dataSource: DataSource, source: O)
        -> Disposable where DataSource.Element == S, O.E == S  {
            return source.subscribeProxyDataSource(ofObject: self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxNSTableViewDataSourceProxy, event) -> Void in
                guard let tableView = self else {
                    return
                }
                dataSource.tableView(tableView: tableView, observedEvent: event)
            }
    }

    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var rx_delegate: DelegateProxy<NSTableView, NSTableViewDelegate> {
        return RxNSTableViewDelegateProxy.proxy(for: self)
    }
    
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.
     
     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createTableViewDelegateProxy() -> RxNSTableViewDelegateProxy {
        return RxNSTableViewDelegateProxy(parentObject: self)
    }
    
    /**
     Factory method that enables subclasses to implement their own `rx_dataSource`.
     
     - returns: Instance of delegate proxy that wraps `dataSource`.
     */
    public func rx_createTableViewDataSourceProxy() -> RxNSTableViewDataSourceProxy {
        return RxNSTableViewDataSourceProxy(parentObject: self)
    }
    
    /**
     Reactive wrapper for `dataSource`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var rx_dataSource: DelegateProxy<NSTableView, NSTableViewDataSource> {
        return RxNSTableViewDataSourceProxy.proxy(for: self)
    }
    
    /**
     Installs data source as forwarding delegate on `rx_dataSource`.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func rx_setDataSource(dataSource: NSTableViewDataSource)
        -> Disposable {
//            let proxy = RxNSTableViewDataSourceProxy.proxy(for: self)
            
            return RxNSTableViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx_delegate`.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func rx_setDelegate(delegate: NSTableViewDelegate)
        -> Disposable {
            return self.rx_setDelegate(delegate: delegate, retainDelegate: false)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx_delegate`, and optionally retains a strong reference to it.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - parameter retainDelegate: Whether or not a strong reference to the delegate should be retained (Note this should typically be false)
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func rx_setDelegate(delegate: NSTableViewDelegate, retainDelegate: Bool)
        -> Disposable {
//            let proxy: RxNSTableViewDelegateProxy = RxNSTableViewDelegateProxy.proxy(for: self)
            return RxNSTableViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: retainDelegate, onProxyForObject: self)
    }
}
