import Foundation

public typealias Matrix<R: Ring> = _Matrix<Dynamic, Dynamic, R>

public struct _Matrix<n: _Int, m: _Int, R: Ring>: Module, Sequence {
    public typealias CoeffRing = R
    
    internal var impl: MatrixImpl<R>
    
    internal init(_ impl: MatrixImpl<R>) {
        self.impl = impl
    }
    
    // 1. Initialize by Grid.
    public init(_ grid: [R]) {
        let (rows, cols) = {() -> (Int, Int) in
            if !n.isDynamic && !m.isDynamic {
                return (n.intValue, m.intValue)
            } else if !m.isDynamic && m.intValue == 1 {
                return !n.isDynamic ? (n.intValue, 1) : (grid.count, 1)
            } else if !n.isDynamic && n.intValue == 1 {
                return !m.isDynamic ? (1, m.intValue) : (1, grid.count)
            } else {
                fatalError("cannot determine matrix size.")
            }
        }()
        self.init(MatrixImpl(rows: rows, cols: cols, grid: grid))
    }
    
    public init(_ grid: R...) {
        self.init(grid)
    }
    
    // 2. Initialize by Generator.
    public init(generator g: (Int, Int) -> R) {
        assert(!n.isDynamic && !m.isDynamic)
        let (rows, cols) = (n.intValue, m.intValue)
        self.init(MatrixImpl(rows: rows, cols: cols, generator: g))
    }
    
    // 3. Initialize by Components.
    public init(components: [MatrixComponent<R>]) {
        assert(!n.isDynamic && !m.isDynamic)
        let (rows, cols) = (n.intValue, m.intValue)
        self.init(MatrixImpl(rows: rows, cols: cols, components: components))
    }
    
    // Convenience initializers
    public init(fill a: R) {
        self.init() { (_, _) in a }
    }
    
    public init(diagonal d: [R]) {
        self.init() { (i, j) in (i == j && i < d.count) ? d[i] : .zero }
    }
    
    public init(scalar a: R) {
        self.init() { (i, j) in (i == j) ? a : .zero }
    }
    
    // Block Matrix [A, B; C, D]
    public init<n1, n2, m1, m2>(_ A: _Matrix<n1, m1, R>, _ B: _Matrix<n1, m2, R>, _ C: _Matrix<n2, m1, R>, _ D: _Matrix<n2, m2, R>) {
        let (n1, n2, m1, m2) = (n1.intValue, n2.intValue, m1.intValue, m2.intValue)
        assert(n1 + n2 == n.intValue)
        assert(m1 + m2 == m.intValue)
        self.init() { (i, j) in
            switch (i, j) {
            case (i, j) where i <  n1 && j <  m1: return A[i, j]
            case (i, j) where i >= n1 && j <  m1: return B[i - n1, j]
            case (i, j) where i <  n1 && j >= m1: return C[i, j - m1]
            case (i, j) where i >= n1 && j >= m1: return D[i - n1, j - m1]
            default: return .zero
            }
        }
    }
    
    public var rows: Int { return impl.rows }
    public var cols: Int { return impl.cols }
    
    private mutating func willMutate() {
        if !isKnownUniquelyReferenced(&impl) {
            impl = impl.copy()
        }
    }
    
    public subscript(i: Int, j: Int) -> R {
        get {
            return impl[i, j]
        } set {
            willMutate()
            impl[i, j] = newValue
        }
    }
    
    public static var zero: _Matrix<n, m, R> {
        return _Matrix<n, m, R> { _,_ in .zero }
    }
    
    public static func unit(_ i0: Int, _ j0: Int) -> _Matrix<n, m, R> {
        return _Matrix { (i, j) in (i, j) == (i0, j0) ? .identity : .zero }
    }
    
    public static func ==(a: _Matrix<n, m, R>, b: _Matrix<n, m, R>) -> Bool {
        return a.impl == b.impl
    }
    
    public static func +(a: _Matrix<n, m, R>, b: _Matrix<n, m, R>) -> _Matrix<n, m, R> {
        return _Matrix(a.impl + b.impl)
    }
    
    public prefix static func -(a: _Matrix<n, m, R>) -> _Matrix<n, m, R> {
        return _Matrix(-a.impl)
    }
    
    public static func *(r: R, a: _Matrix<n, m, R>) -> _Matrix<n, m, R> {
        return _Matrix(r * a.impl)
    }
    
    public static func *(a: _Matrix<n, m, R>, r: R) -> _Matrix<n, m, R> {
        return _Matrix(a.impl * r)
    }
    
    public static func * <p>(a: _Matrix<n, m, R>, b: _Matrix<m, p, R>) -> _Matrix<n, p, R> {
        return _Matrix<n, p, R>(a.impl * b.impl)
    }
    
    public var transposed: _Matrix<m, n, R> {
        return _Matrix<m, n, R>(impl.transposed)
    }
    
    public func rowVector(_ i: Int) -> _RowVector<m, R> {
        return _submatrix(i ..< i + 1, 0 ..< cols)
    }
    
    public func colVector(_ j: Int) -> _ColVector<n, R> {
        return _submatrix(0 ..< rows, j ..< j + 1)
    }
    
    public func submatrix(_ rowRange: CountableRange<Int>, _ colRange: CountableRange<Int>) -> Matrix<R> {
        return _submatrix(rowRange, colRange)
    }
    
    internal func _submatrix<k: _Int, l: _Int>(_ rowRange: CountableRange<Int>, _ colRange: CountableRange<Int>) -> _Matrix<k, l, R> {
        return _Matrix<k, l, R>(impl.submatrix(rowRange, colRange))
    }
    
    public var grid: [R] {
        return impl.grid
    }
    
    public var components: [MatrixComponent<R>] {
        return impl.components
    }
    
    // TODO directly iterate impl
    public func makeIterator() -> IndexingIterator<[(Int, Int, R)]> {
        return components.map{ c in (c.row, c.col, c.value) }.makeIterator()
    }
    
    public var hashValue: Int {
        return impl.hashValue
    }
    
    public var description: String {
        return "[" + (0 ..< rows).map({ i in
            return (0 ..< cols).map({ j in
                return "\(self[i, j])"
            }).joined(separator: ", ")
        }).joined(separator: "; ") + "]"
    }
    
    public var detailDescription: String {
        if (rows, cols) == (0, 0) {
            return "[]"
        } else if rows == 0 {
            return "[" + String(repeating: "\t,", count: cols - 1) + "\t]"
        } else if cols == 0 {
            return "[" + String(repeating: "\t;", count: rows - 1) + "\t]"
        } else {
            return "[\t" + (0 ..< rows).map({ i in
                return (0 ..< cols).map({ j in
                    return "\(self[i, j])"
                }).joined(separator: ",\t")
            }).joined(separator: "\n\t") + "]"
        }
    }
    
    public static var symbol: String {
        if !m.isDynamic && m.intValue == 1 {
            if !n.isDynamic {
                return "Vec<\(n.intValue); \(R.symbol)>"
            } else {
                return "Vec<\(R.symbol)>"
            }
        }
        if !n.isDynamic && n.intValue == 1 {
            if !m.isDynamic {
                return "rVec<\(m.intValue); \(R.symbol)>"
            } else {
                return "rVec<\(R.symbol)>"
            }
        }
        if !n.isDynamic && !m.isDynamic {
            return "Mat<\(n.intValue), \(m.intValue); \(R.symbol)>"
        } else {
            return "Mat<\(R.symbol)>"
        }
    }
}

public extension _Matrix where n == Dynamic, m == Dynamic {
    public init(rows: Int, cols: Int, grid: [R]) {
        self.init(MatrixImpl(rows: rows, cols: cols, grid: grid))
    }
    
    public init(rows: Int, cols: Int, grid: R ...) {
        self.init(rows: rows, cols: cols, grid: grid)
    }
    
    public init(rows: Int, cols: Int, generator g: (Int, Int) -> R) {
        self.init(MatrixImpl(rows: rows, cols: cols, generator: g))
    }
    
    public init(rows: Int, cols: Int, components: [MatrixComponent<R>]) {
        self.init(MatrixImpl(rows: rows, cols: cols, components: components))
    }
    
    public init(rows: Int, cols: Int, fill a: R) {
        self.init(rows: rows, cols: cols) { (_, _) in a }
    }
    
    public init(rows: Int, cols: Int, diagonal d: [R]) {
        self.init(rows: rows, cols: cols) { (i, j) in (i == j && i < d.count) ? d[i] : .zero }
    }
    
    public init(size n: Int, scalar a: R) {
        self.init(rows: n, cols: n) { (i, j) in (i == j) ? a : .zero }
    }
    
    public static func identity(size n: Int) -> Matrix<R> {
        return Matrix(size: n, scalar: .identity)
    }
    
    public static func zero(rows: Int, cols: Int) -> Matrix<R> {
        return Matrix(rows: rows, cols: cols) { (_, _) in .zero }
    }
    
    public static func unit(rows: Int, cols: Int, _ coord: (Int, Int)) -> Matrix<R> {
        return Matrix(rows: rows, cols: cols) { (i, j) in (i, j) == coord ? .identity : .zero }
    }
}

extension _Matrix: VectorSpace, FiniteDimVectorSpace where R: Field {
    public static var dim: Int {
        assert(!n.isDynamic && !m.isDynamic)
        return n.intValue * m.intValue
    }
    
    public static var standardBasis: [_Matrix<n, m, R>] {
        assert(!n.isDynamic && !m.isDynamic)
        return (0 ..< n.intValue).flatMap { i -> [_Matrix<n, m, R>] in
            (0 ..< m.intValue).map { j -> _Matrix<n, m, R> in
                _Matrix.unit(i, j)
            }
        }
    }
    
    public var standardCoordinates: [R] {
        return grid
    }
}

public extension _Matrix where R: EuclideanRing {
    public func eliminate(form: MatrixForm = .Diagonal) -> MatrixEliminationResultWrapper<n, m, R> {
        let result = impl.copy().eliminate(form: form)
        return MatrixEliminationResultWrapper(self, result)
    }
}

extension _Matrix: NormedSpace where R: NormedSpace {
    public var norm: 𝐑 {
        return √( sum { (_, _, a) in a.norm.pow(2) } )
    }
    
    public var maxNorm: 𝐑 {
        return self.map { $0.2.norm }.max() ?? 𝐑.zero
    }
}

public extension _Matrix where R == 𝐑 {
    public var asComplex: _Matrix<n, m, 𝐂> {
        return _Matrix<n, m, 𝐂>(impl.mapValues{ $0.asSuper })
    }
}

public extension _Matrix where R == 𝐂 {
    public var realPart: _Matrix<n, m, 𝐑> {
        return _Matrix<n, m, 𝐑>(impl.mapValues{ $0.realPart })
    }
    
    public var imaginaryPart: _Matrix<n, m, 𝐑> {
        return _Matrix<n, m, 𝐑>(impl.mapValues{ $0.imaginaryPart })
    }
    
    public var adjoint: _Matrix<m, n, R> {
        return _Matrix<m, n, R>(impl.transposed.mapValues{ $0.conjugate })
    }
}
