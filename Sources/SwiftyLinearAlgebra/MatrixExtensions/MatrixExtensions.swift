//
//  Matrix.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/06/16.
//

import Foundation
import SwiftyMath

extension Matrix: VectorSpace, FiniteDimVectorSpace where R: Field, n: StaticSizeType, m: StaticSizeType {
    public static var dim: Int {
        return n.intValue * m.intValue
    }
    
    public static var standardBasis: [Matrix<n, m, R>] {
        return (0 ..< n.intValue).flatMap { i -> [Matrix<n, m, R>] in
            (0 ..< m.intValue).map { j -> Matrix<n, m, R> in
                Matrix.unit(i, j)
            }
        }
    }
    
    public var standardCoordinates: [R] {
        return grid
    }
}

