
var OCLLibrary = {
    __asArray(x) {
        if (Array.isArray(x)) {
            return x;
        }
        else {
            return [x];
        }
    },

    size(collection) {
        return this.__asArray(collection).length;
    },

    notEmpty(collection) {
        return this.size(collection) != 0;
    },

    empty(collection) {
        return this.size(collection) == 0;
    },

    union(lhs, rhs) {
        return lhs.concat(rhs);
    },

    at(collection, idx) {
        return this.__asArray(collection)[idx - 1];
    },

    subSequence(collection, start, end) {
        return this.__asArray(collection).slice(start - 1, end);
    },

    sum(collection) {
        return this.__asArray(collection).reduce((acc, val) => acc + val);
    },

    iterate(collection, seed, lambda) {
        return this.__asArray(collection).reduce(lambda, seed);
    },

    collect(collection, lambda) {
        return this.__asArray(collection).map(lambda);
    },

    zipWith(left, right, lambda) {
	const length = Math.min(left.length, right.length);
        return left.slice(0, length).map((v, idx) => lambda(v, right[idx]));
    },

    prepend(collection, element) {
        return [element].concat(collection);
    },

    includes(collection, element) {
        return this.__asArray(collection).includes(element);
    },

    oclIsUndefined(val) {
        return val ? false : true;
    },

    oclType(val) {
        //TODO implement oclType
    },

    oclIsKindOf(val, type) {
        //TODO implement oclIsKindOf
    },

    toString(val) {
        return val.toString();
    },

    asOrderedSet(collection) {
        return new Set(collection);
    },

    startWiths(str, prefix) {
        return str.startWiths(prefix);
    },

    first(collection) {
        return this.__asArray(collection)[0];
    },

    last(collection) {
        let c = this.__asArray(collection);
        return c[c.length - 1];
    },

    toInteger(string) {
        return string * 1;
    },
}


