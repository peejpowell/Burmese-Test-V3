//
//  TextFinderClientProtocols.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 14/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

/// Defines various methods for providing the indexing of the words in the logical long string

protocol TextFinderIndexing : NSTextFinderClient {
    
    /**
     Find the column for the columnIndex in our searchable word indexes
     - Parameter colIndex: index of the column
     
     - Returns: an Int giving the index in tableView.tableColumns of the column indicated by colIndex
     */
    
    func tableColumnForColIndex(_ colIndex: Int) -> Int
    
    /**
     Gets the Words item from the datasource that corresponds to the row in the tableView
     - Parameter row: the row for the word in the tableView
     - Returns: The Words item for the row in the tableView
     */
    func recordAtRowCol(_ row: Int)->Words
    
    /**
     Gets the Words item from the datasource that corresponds to the row and column in the tableView
     - Parameter row: the row for the word in the tableView
     - Parameter col: the column for the word in the tableView
     - Returns: The Words item for the row and column in the tableView as NSString
     */
    func wordAtRowCol(_ row: Int, col: Int)->NSString
    
    /**
     Used by the replace function to change the word at the relative location in the dataSource
     - Parameter word:  the new word
     - Parameter row:   the row for the word in the tableView
     - Parameter col:   the column for the word in the tableView
     */
    func setWordAtRowCol(_ word: String, _ row: Int, col: Int)
    
    /**
     Removes any diacritics if ignoreDiacritic has been set
     - Parameter word: the string for the word in the tableView
     - Parameter ignoreDiacritic: Bool for whether to fold or not
     - Returns: The word after removing diacritics or the original word if not as NSString
     */
    func wordOrDiacriticWord(_ word: String?, ignoreDiacritic: Bool)->NSString
    /**
     Gives the array for the location in the flattened string
     - Parameter location: the location of the character in the flattened string
     - Returns: Integer array from the search index for the location
     */
    func arrayForLocation(_ location: Int)->[Int]
    
    /**
     Index the word depending on whether diacritics are being ignored.
     
     - Parameters:
        - word: word to be indexed
        - currentIndex: the index to add
        - row: the row to add to the index
        - col: the column to add to the index
        - ignoreDiacritic: whether diacritics are ignored or not
    - Returns: new index after taking length of the indexed word as Int
     */
    func checkDiacriticAndIndex(_ word: String, currentIndex: Int, row: Int, col: Int, ignoreDiacritic: Bool)->Int
    
    /**
     Make an index of all strings such that we can find any string via that index
     - Returns:
     */
    func calculateIndex()//->Int
}

/// Adds extra options to the built in search menu.

protocol TextFinderMenuSetup {
    
    /**
     Adds some extra options to the built in search menu template.
     
     Options are:
     - Filter Results
     - Ignore Diacritics
     */
    func setUpSearchMenu()
}

/// Defines methods related to the ignore diacritic menu option

protocol TextFinderMenuDiacritic {

    /// Toggles the state of the Ignore Diacitics menu item
    func toggleIgnoreDiactric(state: NSControl.StateValue)
    
    /// Checks if the Ignore Diacritics menu item is checked or not
    /// - Returns: bool to indicate if the item is checked or not.
    func isIgnoreDiacriticChecked()->Bool
    
    /// Defines what to do when the state of Ignore Diacritics changes.
    func changeIgnoreDiacriticState(_ sender: NSMenuItem)
}

/// Defines methods related to the Filter Results menu option

protocol TextFinderMenuFilterResults {
    
}
