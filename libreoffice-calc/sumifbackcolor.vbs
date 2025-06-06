option vbasupport 1

function sumifbackcolor(cells, cell)
	backcolor = cell.CellRange.CellBackColor

	ranges = cells.CellRange
	cols = ranges.Columns.Count - 1
	rows = ranges.Rows.Count - 1

	s = 0
	for i = 0 to cols
		for j = 0 to rows
			c = ranges.getCellByPosition(i, j)
			if c.CellBackColor = backcolor then
				v = c.Value
				s = s + v
			end if
		next j
	next i

	sumifbackcolor = s
end function
