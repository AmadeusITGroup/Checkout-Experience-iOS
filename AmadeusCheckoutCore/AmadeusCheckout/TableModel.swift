//
//  TableModel.swift
//  AmadeusCheckout
//
//  Created by Yann Armelin on 07/08/2019.
//  Copyright © 2019 Amadeus. All rights reserved.
//

import Foundation


class TableModel {
    class Cell: Hashable {
        let identifier: String
        let selectable: Bool
        let height: CGFloat
        
        let segueIdentifier: String?
        let labelKey: String?
        let placeholderKey: String?
        
        private init(_ identifier: String, selectable: Bool, height: CGFloat, segueIdentifier: String?, labelKey: String?, placeholderKey:String?) {
            self.labelKey = labelKey
            self.identifier = identifier
            self.selectable = selectable
            self.placeholderKey = placeholderKey
            self.segueIdentifier = segueIdentifier
            self.height = height
        }
        
        convenience init(_ identifier: String, labelKey: String, height: CGFloat = 44) {
            self.init(identifier, selectable:false, height:height, segueIdentifier:nil, labelKey:labelKey, placeholderKey:nil)
            
        }
        
        convenience init(_ identifier: String, labelKey: String, placeholderKey: String, height: CGFloat = 44) {
            self.init(identifier, selectable:true, height:height, segueIdentifier:nil, labelKey:labelKey, placeholderKey:placeholderKey)
        }
        
        convenience init(_ identifier: String, labelKey: String, segueIdentifier: String, height: CGFloat = 44) {
            self.init(identifier, selectable:true, height:height, segueIdentifier:segueIdentifier, labelKey:labelKey, placeholderKey:nil)
        }
        
        static func == (lhs: Cell, rhs: Cell) -> Bool {
            return lhs.identifier == rhs.identifier
                && lhs.segueIdentifier == rhs.segueIdentifier
                && lhs.labelKey == rhs.labelKey
                && lhs.placeholderKey == rhs.placeholderKey
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
            hasher.combine(segueIdentifier)
            hasher.combine(labelKey)
            hasher.combine(placeholderKey)
        }
    }
    
    class Section {
        var title: String?
        var cells: [Cell] = []
    }

    
    
    var bindingAggregator = DataModelBindingAggregator()
    var sections: [Section] = []
    var bindings: [Cell:[DataModelBinding]] = [:]
    var isOptional: [Cell:Bool] = [:]
    

    func addCell(_ description: Cell ,inSection: Int) {
        sections[inSection].cells.append(description)
    }

    func getCell(at: IndexPath) -> Cell {
        return sections[at.section].cells[at.row]
    }
    
    func getCells() -> [(IndexPath,Cell)] {
        var result: [(IndexPath,Cell)] = []
        for (sectionIdx,section) in sections.enumerated() {
            for (rowIdx,cell) in section.cells.enumerated() {
                result.append((IndexPath(row: rowIdx, section: sectionIdx), cell))
            }
        }
        return result
    }
    
    func addSection(title: String?) -> Int{
        let section = Section()
        section.title = title
        sections.append(section)
        return sections.count - 1
    }
    
    func clear() {
        sections = []
    }
    
    func setBindings(forCell cell: Cell , newBindings: [DataModelBinding]) {
        if let oldBindings = bindings[cell] {
            for binding in oldBindings {
                bindingAggregator.remove(binding)
            }
        }
        bindings[cell] = newBindings
        for binding in newBindings {
            bindingAggregator.add(binding)
        }
    }
    
    func addBinding(forCell cell: Cell , newBinding: DataModelBinding) {
        bindings[cell]?.append(newBinding)
        bindingAggregator.add(newBinding)
    }
    
    func getBindings(forCell cell: Cell) ->[DataModelBinding] {
        return bindings[cell] ?? []
    }
    
    func getBindings() -> [DataModelBinding] {
        var result: [DataModelBinding] = []
        for (_, cellBindings) in bindings {
            result.append(contentsOf: cellBindings)
        }
        return result
    }
    
    func getFirstResponderPath() -> IndexPath? {
        for (sectionIdx,section) in sections.enumerated() {
            for (rowIdx,cell) in section.cells.enumerated() {
                for binding in getBindings(forCell: cell) {
                    if binding.view?.isFirstResponder == true{
                        return IndexPath(row: rowIdx, section: sectionIdx)
                    }
                }
            }
        }
        return nil
    }
    
    func setIsOptional(cell: Cell, value: Bool)  {
        isOptional[cell] = value
    }
    
    func isOptional(cell: Cell)  -> Bool {
        return isOptional[cell] == false
    }
}

