
module Tree
  def appendBuffer(xs, level, buffer)
    if level == 0
      xs[0...-1] + [res]
    else
      res = appendBuffer xs[-1], (level - 1), buffer
      xs[0...-1] + [res]
    end
  end

  def Tree.appendBuffer(*args)
    appendBuffer *args
  end

  def appendList(xs, level, list)
    if level == 0
      xs + [list]
    else
      res = appendList xs[-1], (level - 1), list
      xs[0...-1] + [res]
    end
  end

  def Tree.appendList(*args)
    appendList *args
  end

  def createHelper(xs, n)
    if n <= 1
      xs
    else
      [create xs, (n - 1)]
    end
  end

  def Tree.createNesting(n)
    create [], n
  end

  def dollarHelper(before, after)
    if after.length == 0
      return before
    end
    cursor = after[0]
    if cursor.is_a? Array
      dollarHelper (before + [resolveDollar cursor]), after[1..-1]
    else if cursor.text == '$'
      before + [resolveDollar after[1..-1]]
    else
      dollarHelper (before + [cursor]), after[1..-1]
    end
  end

  def resolveDollar(xs)
    if xs.length == 0 then return xs
    dollarHelper [], xs
  end

  def Tree.resolveDollar(*args)
    resolveDollar *args
  end

  def commaHelper(before, after)
    if after.length == 0
      return before
    end
    cursor = after[0]
    if (cursor.is_a? Array) and (cursor.length > 0)
      head = cursor[0]
      if head.is_a? Array
        commaHelper (before + [resolveComma cursor]), after[1..-1]
      else if head.text == ','
        commaHelper before, ((resolveComma cursor[1..-1]) + after[1..-1])
      else
        commaHelper (before + [resolveComma cursor]), after[1..-1]
      end
    else
      commaHelper (before + [cursor]), after[1..-1]
    end
  end

  def resolveComma(xs)
    if xs.length == 0
      return xs
    end
    commaHelper [], xs
  end

  def Tree.resolveComma(*args)
    resolveComma *args
  end

end