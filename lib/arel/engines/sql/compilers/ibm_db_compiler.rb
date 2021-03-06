# +-----------------------------------------------------------------------+
# |                                                                       |
# | Copyright (c) 2010 IBM Corporation                                    |
# |                                                                       |
# | Permission is hereby granted, free of charge, to any person obtaining |
# | a copy of this software and associated documentation files (the       |
# | "Software"), to deal in the Software without restriction, including   |
# | without limitation the rights to use, copy, modify, merge, publish,   |
# | distribute, sublicense, and/or sell copies of the Software, and to    |
# | permit persons to whom the Software is furnished to do so, subject to |
# | the following conditions:                                             |
# |                                                                       |
# | The above copyright notice and this permission notice shall be        |
# | included in all copies or substantial portions of the Software.       |
# |                                                                       |
# | THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       |
# | EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    |
# | MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
# | IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR      |
# | ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION           |
# | OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION |
# | WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.       |
# |                                                                       |
# +-----------------------------------------------------------------------+

#
#  Author: Praveen Devarao <praveendrl@in.ibm.com>
#

module Arel
  module SqlCompiler
    class IBM_DBCompiler < GenericCompiler

      def select_sql
        query = build_query \
          "SELECT     #{select_clauses.join(', ')}",
          "FROM       #{from_clauses}",
          (joins(self)                                   unless joins(self).blank? ),
          ("WHERE     #{where_clauses.join(" AND ")}"    unless wheres.blank?      ),
          ("GROUP BY  #{group_clauses.join(', ')}"       unless groupings.blank?   ),
          ("HAVING    #{having_clauses.join(', ')}"      unless havings.blank?     ),
          ("ORDER BY  #{order_clauses.join(', ')}"       unless orders.blank?      )
          engine.add_limit_offset!(query,{:limit=>taken,:offset=>skipped}) unless taken.blank?
          query << "#{locked}" unless locked.blank?
          query
      end

      def limited_update_conditions(conditions, taken)
        quoted_primary_key = engine.quote_table_name(primary_key)
        update_conditions = "WHERE #{quoted_primary_key} IN (SELECT #{quoted_primary_key} FROM #{engine.connection.quote_table_name table.name} #{conditions} " #Note: - ')' not added, limit segment is to be appended
        engine.add_limit_offset!(update_conditions,{:limit=>taken,:offset=>nil})
        update_conditions << ")" # Close the sql segment
        update_conditions
      end

      def add_limit_on_delete(taken)
        raise "IBM_DB does not support limit on deletion" # Limiting the number of rows to be deleted is not supported by IBM_DB
      end

    end
  end
end
