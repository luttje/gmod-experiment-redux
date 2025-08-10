--- Creates an index if it doesn't exist
--- @param table string The table name
--- @param index string The index name
--- @param columns string|table The column(s) to index
--- @param callback? fun() Called when the index creation is complete
function mysql:CreateIndexIfNotExists(table, index, columns, callback)
	local columnsStr = type(columns) == "table" and table.concat(columns, ", ") or columns

	if (mysql.module == "mysqloo") then
		mysql:RawQuery(string.format([[
		SELECT 1
		FROM information_schema.STATISTICS
		WHERE table_schema = DATABASE()
		AND table_name = '%s'
		AND index_name = '%s'
	]], table, index), function(result, status)
			if (status and #result == 0) then
				mysql:RawQuery(string.format("CREATE INDEX %s ON %s (%s)", index, table, columnsStr), callback)
			else
				if (callback) then
					callback()
				end
			end
		end)
	elseif (mysql.module == "sqlite") then
		ix.util.SchemaErrorNoHalt("CreateIndexIfNotExists is not yet implemented for SQLite")
	end
end
