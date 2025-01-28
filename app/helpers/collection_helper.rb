module CollectionHelper
  def middle_from_array(arr)
    if arr.length.even?
      arr[(arr.length / 2) - 1]
    else
      arr[arr.length / 2]
    end
  end

  def middle_from_rel(rel)
    rel.offset(rel.size / 2).first
  end

  def average_from_array(arr)
    arr.sum.to_f / arr.size
  end
end
