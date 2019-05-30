//
//  MatrixExtensions.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/05/30.
//

import Foundation
import SwiftyMath

public extension SquareMatrix where n == m, n: StaticSizeType, R == 𝐂 {
    var isHermitian: Bool {
        if rows <= 1 {
            return true
        }
        return (0 ..< rows - 1).allSatisfy { i in
            (i + 1 ..< cols).allSatisfy { j in
                self[i, j] == self[j, i].conjugate
            }
        }
    }
    
    var isSkewHermitian: Bool {
        if rows <= 1 {
            return isZero
        }
        return (0 ..< rows - 1).allSatisfy { i in
            (i + 1 ..< cols).allSatisfy { j in
                self[i, j] == -self[j, i].conjugate
            }
        }
    }
    
    var isUnitary: Bool {
        return self.adjoint * self == .identity
    }
}

public extension SquareMatrix where n == m, n: StaticSizeType {
    static var standardSymplecticMatrix: SquareMatrix<n, R> {
        assert(n.intValue.isEven)
        
        let m = n.intValue / 2
        return SquareMatrix { (i, j) in
            if i < m, j >= m, i == (j - m) {
                return -.identity
            } else if i >= m, j < m, (i - m) == j {
                return .identity
            } else {
                return .zero
            }
        }
    }
}

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
