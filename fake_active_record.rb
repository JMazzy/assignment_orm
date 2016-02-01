module FakeActiveRecord
  class BASE
    # CLASS method on any
    # model object
    # that returns pluralized
    # version of class name
    def self.table_name
      "#{self.name.downcase}s"
    end


    # gives you a hash of {column_name: column_type }
    # for your table
    def self.schema
      return @schema if @schema

      @schema = {}

      # example:
      # If you're a Post
      # runs DB.table_info("posts")
      DB.table_info(table_name) do |row|
        @schema[row["name"]] = row["type"]
      end

      @schema
    end

    # convenience wrapper for your schema's column names
    def self.columns
      schema.keys
    end

    def self.all
      DB.execute("SELECT * from #{self.table_name}")
    end

    def self.find(id)
      if id.is_a?(Array)
        id_list = id.join(",")
        DB.execute("SELECT * FROM #{self.table_name} WHERE id IN (#{id_list})")
      else
        DB.execute("SELECT * FROM #{self.table_name} WHERE id = #{id}")
      end
    end

    def self.first
      DB.execute("SELECT * FROM #{self.table_name} LIMIT 1")
    end

    def self.last
      DB.execute("SELECT * FROM #{self.table_name} ORDER BY id DESC LIMIT 1")
    end

    def self.select(column, *others)
      raise ArgumentError unless self.columns.include?(column)
      columns = "SELECT #{column}"
      others.each do |col|
        raise ArgumentError unless self.columns.include?(col)
        columns += ", #{col}"
      end
      DB.execute(columns + " FROM #{self.table_name}")
    end

    def self.count
      DB.execute("SELECT count(*) FROM #{self.table_name}")
    end

    def self.where(hash)
      query_arr = []
      hash.each do |k,v|
        raise ArgumentError unless self.columns.include?(k)
        query_arr << "#{k} = '#{v}'"
      end
      DB.execute("SELECT * FROM #{self.table_name} WHERE " + query_arr.join(" AND "))
    end

    def self.create(array_or_hash)
      column_arr = []
      value_arr = []

      if array_or_hash.is_a?(Hash)
        array_or_hash.each do |k,v|
          raise ArgumentError unless self.columns.include?(k)
          column_arr << k
          value_arr << v
        end
        DB.execute("INSERT INTO #{self.table_name} (#{column_arr.join(',')}) VALUES (#{value_arr.join(',')}) ")

      elsif array_or_hash.is_a?(Array)
        array_or_hash.each do |hash|
          column_arr = []
          value_arr = []
          hash.each do |k,v|
            raise ArgumentError unless self.columns.include?(k)
            column_arr << k
            value_arr << "'#{v}'"
          end
          DB.execute("INSERT INTO #{self.table_name} (#{column_arr.join(',')}) VALUES (#{value_arr.join(',')}) ")
        end
      end
    end

  end
end
