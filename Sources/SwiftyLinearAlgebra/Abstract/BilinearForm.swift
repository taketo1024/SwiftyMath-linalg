//
//  BilinearForm.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/06/16.
//

import Foundation
import SwiftyMath

public protocol BilinearFormType: MapType, Module
    where Domain: ProductSetType,
    Domain.Left: Module,
    Domain.Right: Module,
    Codomain == CoeffRing,
    CoeffRing == Domain.Left.CoeffRing,
    CoeffRing == Domain.Right.CoeffRing
{
    
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain)
    func applied(to: (Domain.Left, Domain.Right)) -> Codomain
}

public extension BilinearFormType {
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain) {
        self.init { (v: Domain) in f(v.left, v.right) }
    }
    
    func applied(to v: (Domain.Left, Domain.Right)) -> Codomain {
        return applied(to: Domain(v.0, v.1))
    }
    
    static var zero: Self {
        return Self{ v in .zero }
    }
    
    static func +(f: Self, g: Self) -> Self {
        return Self { v in f.applied(to: v) + g.applied(to: v) }
    }
    
    static prefix func -(f: Self) -> Self {
        return Self { v in -f.applied(to: v) }
    }
    
    static func *(r: CoeffRing, f: Self) -> Self {
        return Self { v in r * f.applied(to: v) }
    }
    
    static func *(f: Self, r: CoeffRing) -> Self {
        return Self { v in f.applied(to: v) * r }
    }
}

public extension BilinearFormType where Domain.Left: FiniteDimVectorSpace, Domain.Right: FiniteDimVectorSpace {
    var asMatrix: DMatrix<CoeffRing> {
        typealias V = Domain.Left
        typealias W = Domain.Right
        
        let (n, m) = (V.dim, W.dim)
        let (Vbasis, Wbasis) = (V.standardBasis, W.standardBasis)
        
        return DMatrix(rows: n, cols: m) { (i, j) in
            let (v, w) = (Vbasis[i], Wbasis[j])
            return self.applied(to: (v, w))
        }
    }
}

public struct BilinearForm<V1: Module, V2: Module>: BilinearFormType where V1.CoeffRing == V2.CoeffRing {
    public typealias CoeffRing = V1.CoeffRing
    public typealias Domain = ProductModule<V1, V2>
    public typealias Codomain = CoeffRing
    
    private let fnc: (Domain) -> Codomain
    public init(_ fnc: @escaping (Domain) -> Codomain) {
        self.fnc = fnc
    }
    
    public func applied(to v: ProductModule<V1, V2>) -> Codomain {
        return fnc(v)
    }
}

