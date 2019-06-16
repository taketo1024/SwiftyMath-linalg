//
//  EigenValuesTests.swift
//  SwiftyLinearAlgebraTests
//
//  Created by Taketo Sano on 2019/06/16.
//

import XCTest
import SwiftyMath

class CharacteristicPolynomialTests: XCTestCase {

    typealias M<n: StaticSizeType, R: Ring> = SquareMatrix<n, R>
    
    func testCharacteristicPolynomial() {
        let A = M<_4, 𝐂>(
            -2, -7, 2, -5,
            1, 2, 0, 1,
            3, 7, -1, 5,
            1, 3, -1, 3
        )
        let f = A.characteristicPolynomial
        XCTAssertEqual(f, xPolynomial<𝐂>(coeffs: 0, 0, 1, -2, 1))
        XCTAssertTrue(f.evaluate(at: A).isZero) // Cayley-Hamilton thm
    }
    
    func testEigenValues() {
        let A = M<_4, 𝐂>(
            -2, -7, 2, -5,
            1, 2, 0, 1,
            3, 7, -1, 5,
            1, 3, -1, 3
        )
        let evs = A.characteristicPolynomial.findAllRoots()
        XCTAssertEqual(Set(evs), Set([0, 0, 1, 1]))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
