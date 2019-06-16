//
//  MatrixFunctions.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/06/16.
//

import Foundation
import SwiftyMath

public func exp<n, K>(_ A: SquareMatrix<n, K>) -> SquareMatrix<n, K> where K: Field, K: NormedSpace {
    if A == .zero {
        return .identity
    }
    
    // X = I + A + A^2/2 + A^3/6 + ...
    var X = SquareMatrix<n, K>.identity
    
    
    var n = 0
    var cn = K.identity
    var An = X
    let e = (1.0).ulp
    
    while n < 1000 {
        n  = n + 1
        An = An * A
        cn = cn / K(from: n)
        
        let Bn = cn * An
        if Bn.maxNorm <= e {
            break
        } else {
            X = X + Bn
        }
    }
    
    return X
}
