//
//  EigenValues.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/06/15.
//

import Foundation
import SwiftyMath

public struct _λ: PolynomialIndeterminate {
    public static var symbol = "λ"
}

public extension Matrix where n == m, n: StaticSizeType, R: Field {
    var characteristicPolynomial: Polynomial<_λ, R> {
        typealias P = Polynomial<_λ, R>
        let λ = P.indeterminate
        let I = SquareMatrix<n, P>.identity
        let A = self.mapNonZeroComponents{ P($0) }
        return (λ * I - A).determinant
    }
}
