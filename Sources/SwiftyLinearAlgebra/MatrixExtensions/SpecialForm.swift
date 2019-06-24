//
//  MatrixExtensions.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/05/30.
//

import Foundation
import SwiftyMath

extension Matrix where n == m, n: StaticSizeType {
    public var isDiagonal: Bool {
        return self.nonZeroComponents.allSatisfy{ c in c.col == c.row }
    }
    
    public var isSymmetric: Bool {
        return self == self.transposed
    }
    
    public var isSkewSymmetric: Bool {
        return self == -self.transposed
    }
    
    public var isOrthogonal: Bool {
        return self.transposed * self == .identity
    }
}

public extension SquareMatrix where n == m, n: StaticSizeType, R == 𝐂 {
    var isNormal: Bool {
        let adj = self.adjoint
        return adj * self == self * adj
    }
    
    var isHermitian: Bool {
        return self == self.adjoint
    }
    
    var isSkewHermitian: Bool {
        return self == -self.adjoint
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
