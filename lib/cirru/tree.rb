
module Tree
  def self.appendBuffer(*args)
    appendBufferHelper(*args)
  end

  def self.appendList(*args)
    appendListHelper(*args)
  end

  def self.createNesting(n)
    createHelper [], n
  end

  def self.resolveDollar(*args)
    # p 'resolveDollar args', args
    resolveDollarHelper *args
  end

  def self.resolveComma(*args)
    resolveCommaHelper(*args)
  end
end

def appendBufferHelper(xs, level, buffer)
  if level == 0
    xs[0..-1] + [buffer]
  else
    res = appendBufferHelper xs[-1], (level - 1), buffer
    xs[0...-1] + [res]
  end
end

def appendListHelper(xs, level, list)
  if level == 0
    xs + [list]
  else
    res = appendListHelper xs[-1], (level - 1), list
    xs[0...-1] + [res]
  end
end

def createHelper(xs, n)
  if n <= 1
    xs
  else
    list = createHelper xs, (n - 1)
    [list]
  end
end


def dollarHelper(before, after)
  if after.length == 0
    return before
  end
  cursor = after[0]
  if cursor.is_a? Array
    chunk = resolveDollarHelper cursor
    dollarHelper (before + [chunk]), after[1..-1]
  elsif cursor[:text] == '$'
    chunk = resolveDollarHelper after[1..-1]
    before + [chunk]
  else
    dollarHelper (before + [cursor]), after[1..-1]
  end
end

def resolveDollarHelper(xs)
  # p 'calling resolveDollarHelper', xs
  if xs.length == 0
    return xs
  end
  dollarHelper [], xs
end

def commaHelper(before, after)
  if after.length == 0
    return before
  end
  cursor = after[0]
  if (cursor.is_a? Array) and (cursor.length > 0)
    head = cursor[0]
    if head.is_a? Array
      chunk = resolveCommaHelper cursor
      commaHelper (before + [chunk]), after[1..-1]
    elsif head[:text] == ','
      commaHelper before, ((resolveCommaHelper cursor[1..-1]) + after[1..-1])
    else
      chunk = resolveCommaHelper cursor
      commaHelper (before + [chunk]), after[1..-1]
    end
  else
    commaHelper (before + [cursor]), after[1..-1]
  end
end

def resolveCommaHelper(xs)
  if xs.length == 0
    return xs
  end
  commaHelper [], xs
end
