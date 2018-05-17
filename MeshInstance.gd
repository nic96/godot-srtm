extends MeshInstance

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(SpatialMaterial) var material = null
export(int) var initial_elevation = -1270.0
export(int) var elevation_divisor = 20.0


# this function is currently unused,
# but in the future I might use it to
# properly position the mesh in a globe
func lla_to_xyz(lon, lat, alt): # Lon Lat Alt to x y z converter.
	var cosLat = cos(lat * PI / 180.0);
	var sinLat = sin(lat * PI / 180.0);
	var cosLon = cos(lon * PI / 180.0);
	var sinLon = sin(lon * PI / 180.0);
	var rad = 6378137.0;
	var f = 1.0 / 298.257224;
	var C = 1.0 / sqrt(cosLat * cosLat + (1 - f) * (1 - f) * sinLat * sinLat);
	var S = (1.0 - f) * (1.0 - f) * C;
	return Vector3((rad * C + alt) * cosLat * cosLon, (rad * C + alt) * cosLat * sinLon, (rad * S + alt) * sinLat)


func _ready():
	var data = []
	var row_length = 1201
	var f = File.new()
	f.endian_swap = true
	f.open("res://Resources/N51W115.hgt", File.READ)
	for x in range(row_length):
		data.append([])
		for y in range(row_length):
			data[x].append(f.get_16())
	f.close()

	var surftool = SurfaceTool.new()
	var mesh = Mesh.new()

	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surftool.add_smooth_group(true)
	surftool.set_material(material)

	for x in range(row_length-1):
		for y in range(row_length-1):
			var corner0 = Vector3(x+1, (data[x+1][y] + initial_elevation) / elevation_divisor, y)
			var corner1 = Vector3(x+1, (data[x+1][y+1] + initial_elevation) / elevation_divisor, y+1)
			var corner2 = Vector3(x, (data[x][y+1] + initial_elevation) / elevation_divisor, y+1)
			var corner3 = Vector3(x, (data[x][y] + initial_elevation) / elevation_divisor, y)

			# bottom left
			surftool.add_vertex(corner0)

			# top left
			surftool.add_vertex(corner1)

			# top right
			surftool.add_vertex(corner2)

			# bottom right
			surftool.add_vertex(corner3)

			# bottom left
			surftool.add_vertex(corner0)

			# top right
			surftool.add_vertex(corner2)

	surftool.generate_normals()
	surftool.index()

	self.set_mesh(surftool.commit())
