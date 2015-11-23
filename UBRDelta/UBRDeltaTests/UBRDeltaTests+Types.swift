//
//  UBRDeltaTests+Types.swift
//  UBRDelta
//
//  Created by Karsten Bruns on 17/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import Foundation
import UBRDelta

struct Captain {
    
    let name: String
    var ships: [String]
    var fistFights: Int
    
    init(name: String, ships: [String], fistFights: Int) {
        self.name = name
        self.ships = ships
        self.fistFights = fistFights
    }
    
}


extension Captain : ComparableItem {
    
    var uniqueIdentifier: Int {
        return name.hash
    }
    
    
    func compareTo(other: ComparableItem) -> ComparisonLevel {
        guard uniqueIdentifier == other.uniqueIdentifier else { return .Different }
        guard let otherPlayer = other as? Captain else { return .Different }
        
        let shipsChanged = ships != otherPlayer.ships
        let fistFightsChanged = fistFights != otherPlayer.fistFights
        
        if !shipsChanged && !fistFightsChanged {
            return .Same
        } else {
            return .Changed(["ships":shipsChanged, "fistFights": fistFightsChanged])
        }
    }
    
}


extension Captain : Equatable { }

func ==(lhs: Captain, rhs: Captain) -> Bool {
    return lhs.compareTo(rhs) == ComparisonLevel.Same
}