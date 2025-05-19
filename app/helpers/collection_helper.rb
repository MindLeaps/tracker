module CollectionHelper
  require 'csv'
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

  def csv_from_array_of_hashes(arr)
    CSV.generate(col_sep: ',') do |csv|
      # Define headers from first item
      csv << arr.first.keys
      arr.each do |item|
        csv << item.values
      end
    end
  end
end
