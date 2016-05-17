func memoize<In:Hashable, Out>(f: In -> Out) -> In -> Out {
    var cache = [In:Out]()
    return { x in
        if let existing = cache[x] { return existing }
        let value = f(x)
        cache[x] = value
        return value
    }
}