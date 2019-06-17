//
//  NormedSpace.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/05/30.
//

import Foundation
import SwiftyMath

// MEMO not made as a subprotocol of VectorSpace,
// to avoid multi-inheritance.
public protocol NormedSpace {
    var norm: 𝐑 { get }
}

extension 𝐐: NormedSpace {
    public var norm: 𝐑 {
        return 𝐑(from: abs)
    }
}

extension 𝐑: NormedSpace {
    public var norm: 𝐑 {
        return abs
    }
}

extension 𝐂: NormedSpace {
    public var norm: 𝐑 {
        return abs
    }
}

extension 𝐇: NormedSpace {
    public var norm: 𝐑 {
        return abs
    }
}

extension Matrix: NormedSpace where R: NormedSpace {
    public var norm: 𝐑 {
        return √( nonZeroComponents.sum { (_, _, a) in a.norm.pow(2) } )
    }
    
    public var maxNorm: 𝐑 {
        return nonZeroComponents.map { $0.2.norm }.max() ?? 𝐑.zero
    }
}
