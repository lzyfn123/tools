# 以table的格式输出
# keys   = %w[Feb2018 Feb2017 Change Programming-Language Ratings Change]
# values = [
#   %w[1 1 - Java 14.988% -1.69%],
#   %w[2 2 - C 11.857% +3.41%],
#   %w[3 3 - C++ 5.726% +0.30%],
#   %w[4 5 ↑ Python 5.168% +1.12%],
#   %w[5 4 ↓ C# 4.453% -0.45%],
#   %w[... ... - ... ... ...],
#   %w[10 11 ↑ Ruby 2.018% -0.29%]
# ]
# TableFormat::Format.new(keys, values).table_format
#
# 输出结果
# +---------+---------+--------+----------------------+---------+--------+
# | Feb2018 | Feb2017 | Change | Programming-Language | Ratings | Change |
# +---------+---------+--------+----------------------+---------+--------+
# |    1    |    1    |   -    |         Java         | 14.988% | -1.69% |
# |    2    |    2    |   -    |          C           | 11.857% | +3.41% |
# |    3    |    3    |   -    |         C++          | 5.726%  | +0.30% |
# |    4    |    5    |   ↑    |        Python        | 5.168%  | +1.12% |
# |    5    |    4    |   ↓    |          C#          | 4.453%  | -0.45% |
# |   ...   |   ...   |   -    |         ...          |   ...   |  ...   |
# |   10    |   11    |   ↑    |         Ruby         | 2.018%  | -0.29% |
# +---------+---------+--------+----------------------+---------+--------+
#

module TableFormat
  class Format
    def initialize(keys, values, out=STDERR)
      @gap       = 2
      @line_mark = '-'
      @keys      = keys
      @values    = values
      @out       = out
    end
    
    def table_format
      print_line
      print_title
      print_line
      print_values
      print_line
    end
    
    def print_title
      print_row(@keys)
    end
    
    def print_values
      @values.map do |row|
        print_row(row)
      end
    end
    
    def print_line
      str = max_size_arr.map do |size|
        "#{get_column_chars(size)}"
      end.join('+')
      
      @out.puts "+#{str}+"
    end
    
    def max_size_arr
      return @_max_size_arr if @_max_size_arr
      
      res      = []
      list_arr = @values.transpose
      @keys.each_with_index do |key, index|
        max = key.to_s.length
        list_arr[index].each { |val| num = val.to_s.length; max = num if num > max }
        res[index] = max
      end
      
      @_max_size_arr = res
    end
    
    private
    
    def print_row(row)
      str = '|'
      ms  = max_size_arr
      
      row.each_with_index do |key, index|
        str += "#{get_column_val(key, ms[index])}|"
      end
      
      @out.puts str
    end
    
    def get_column_chars(num)
      @line_mark * (num + @gap)
    end
    
    def get_column_val(val, num)
      str   = val.to_s
      space = num - str.length + @gap
      return str if space <= 0
      
      left  = ' ' * (space / 2)
      right = ' ' * (space - left.length)
      "#{left}#{str}#{right}"
    end
  end
end
