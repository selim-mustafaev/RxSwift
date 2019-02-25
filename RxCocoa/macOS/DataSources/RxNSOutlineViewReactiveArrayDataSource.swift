//
//  RxNSOutlineViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 17/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

// objc monkey business
public class _RxNSOutlineViewReactiveArrayDataSource: NSObject, NSOutlineViewDataSource {
    func _outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        rxAbstractMethod()
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return _outlineView(outlineView, child: index, ofItem: item)
    }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView: outlineView, numberOfChildrenOfItem: item) > 0
    }

    func _outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 0
    }

    public func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return _outlineView(outlineView, numberOfChildrenOfItem: item)
    }

    func _outlineView(_ outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return nil
    }

    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return _outlineView(outlineView, objectValueForTableColumn: tableColumn, byItem: item)
    }
}

public class RxNSOutlineViewReactiveArrayDataSourceSequenceWrapper<S: Sequence>
    : RxNSOutlineViewReactiveArrayDataSource<S.Iterator.Element>, RxNSOutlineViewDataSourceType where S.Iterator.Element : NSObject {

    public typealias Element = S

    public override init(childrenFactory: @escaping ChildrenFactory) {
        super.init(childrenFactory: childrenFactory)
    }

    public func outlineView(outlineView: NSOutlineView, observedEvent: Event<S>) {
        switch observedEvent {
        case .next(let value):
            super.outlineView(outlineView: outlineView, observedElements: Array(value))
        case .error(let error):
            bindingError(error)
        case .completed:
            break
        }
    }
}

class Node<E> {
    var value: E?
    var children: [Node]

    init(value: E? = nil) {
        self.value = value
        self.children = []
    }
}

// Please take a look at `DelegateProxyType.swift`
public class RxNSOutlineViewReactiveArrayDataSource<Element: NSObject> : _RxNSOutlineViewReactiveArrayDataSource {
    public typealias ChildrenFactory = (Element) -> [Element]

    var root: Node<Element> = Node()

    let childrenFactory: ChildrenFactory

    public init(childrenFactory: @escaping ChildrenFactory) {
        self.childrenFactory = childrenFactory
    }

    override func _outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if (item == nil) {
            return root.children[index].value!
        } else {
            return childrenFactory(item as! Element)[index]
        }
    }

    override func _outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item == nil) {
            return root.children.count
        } else {
            return childrenFactory(item as! Element).count
        }
    }

    override func _outlineView(_ outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }

    // reactive

    private func update(_ node: Node<Element>, withValue value: Element, inOutline outline: NSOutlineView) -> [Int?] {
        let old = node.value
        node.value = value
        outline.reloadItem(old) // by itself not enough - by design (!) http://stackoverflow.com/questions/19963031/nsoutlineview-reloaditem-has-no-effect
        let index = outline.row(forItem: value)
        let replacedIndex: Int? = index >= 0 ? index : nil
        return [replacedIndex] + update(node, withChildren: childrenFactory(value), inOutline: outline)
    }

    private func update(_ node: Node<Element>, withChildren children: [Element], inOutline outline: NSOutlineView) -> [Int?] {
        return children.enumerated().map { (index, childValue) -> [Int?] in
            let childNode: Node<Element>
            if index == node.children.count {
                childNode = Node(value: childValue)
                node.children.append(childNode)
                outline.insertItems(at: IndexSet([index]), inParent: node.value, withAnimation: NSTableView.AnimationOptions.effectFade)
            } else {
                childNode = node.children[index]
            }

            return update(childNode, withValue: childValue, inOutline: outline)
        }.reduce([]){ $0 + $1 }
    }

    func outlineView(outlineView: NSOutlineView, observedElements: [Element]) {
        outlineView.beginUpdates()
        let indices = update(root, withChildren: observedElements, inOutline: outlineView).compactMap { $0 }

        for element in observedElements {
            outlineView.reloadItem(element)
        }

        if indices.count > 0 {
            outlineView.reloadData(forRowIndexes: IndexSet(indices), columnIndexes: IndexSet([0]))
        } else {
            outlineView.reloadData()
        }
        outlineView.endUpdates()
    }
}
