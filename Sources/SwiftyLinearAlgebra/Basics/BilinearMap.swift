//
//  BilinearMap.swift
//  SwiftyLinearAlgebra
//
//  Created by Taketo Sano on 2019/06/16.
//

import Foundation
import SwiftyMath

public protocol BilinearMapType: MapType, VectorSpace
    where Domain: ProductSetType,
    Domain.Left: VectorSpace,
    Domain.Right: VectorSpace,
    Codomain: VectorSpace,
    CoeffRing == Domain.Left.CoeffRing,
    CoeffRing == Domain.Right.CoeffRing,
CoeffRing == Codomain.CoeffRing {
    
    init(_ f: @escaping (Domain.Left, Domain.Right) -> Codomain)
    func applied(to: (Domain.Left, Domain.Right)) -> Codomain
}

public extension BilinearMapType {
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

public struct BilinearMap<V1: VectorSpace, V2: VectorSpace, W: VectorSpace>: BilinearMapType where V1.CoeffRing == V2.CoeffRing, V1.CoeffRing == W.CoeffRing {
    public typealias CoeffRing = V1.CoeffRing
    public typealias Domain = ProductVectorSpace<V1, V2>
    public typealias Codomain = W
    
    private let fnc: (ProductVectorSpace<V1, V2>) -> W
    public init(_ fnc: @escaping (ProductVectorSpace<V1, V2>) -> W) {
        self.fnc = fnc
    }
    
    public func applied(to v: ProductVectorSpace<V1, V2>) -> W {
        return fnc(v)
    }
}
