//
//  EigenValues.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/06/15.
//

import Foundation
import SwiftyMath

public extension Matrix where n == m, n: StaticSizeType {
    var characteristicMatrix: SquareMatrix<n, xPolynomial<R>> {
        typealias P = xPolynomial<R>
        let x = P.indeterminate
        let I = SquareMatrix<n, P>.identity
        let A = self.mapNonZeroComponents{ P($0) }
        return x * I - A
    }
    
    var characteristicPolynomial: xPolynomial<R> {
        return characteristicMatrix.determinant
    }
}
