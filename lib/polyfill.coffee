module.exports = 
  extend: (Class, method, value) ->
    return if Class.prototype[method]?
    Object.defineProperty Class::, method,
      enumerable: no
      configurable: no
      writable: no
      value: value
