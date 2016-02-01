class Article
  # notice that this is a CLASS method
  def self.all
    "SELECT articles.*"
  end

  def self.find(:id)
    if id.is_a?(Array)
      id_list = id.join(",")
      "SELECT * FROM articles WHERE id IN (#{id_list})"
    else
      "SELECT * FROM articles WHERE id = #{id}"
    end
  end

  def self.first
    "SELECT * FROM articles LIMIT 1"
  end

  def self.first
    "SELECT * FROM articles ORDER BY id DESC LIMIT 1"
  end

  def self.select(column, *others)
    columns = "SELECT #{column}"
    *others.each do |col|
      columns += ", #{col}"
    end
    columns += " FROM articles"
  end

  def self.count
    "SELECT count(*) FROM articles"
  end

  def self.where(hash)
    query_arr = []
    hash.each do |k,v|
      query_arr << "#{k} = #{v}"
    end
    "SELECT * FROM articles WHERE " + query_arr.join(" AND ")
  end
end
