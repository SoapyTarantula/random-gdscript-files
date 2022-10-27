# Takes three floats and a bool to return a random Vector2 or Vector3 
# with the floats as maximum possible values and the bool deciding
# if it returns a Vector2 or Vector3. True means Vector3.

# I made it because Godot doesn't have a way (that I know of at least) of directly
# randomizing vectors, and I was getting tired of manually doing it each time.

# Poorly designed by SoapyTarantula
# https://github.com/SoapyTarantula | https://twitter.com/SoapyTarantula

func RandomVector(xMax: float, yMax: float, zMax: float, isVector3: bool):
	var randVec3
	var randVec2

	if isVector3:
		randVec3 = Vector3(randf() * xMax, randf() * yMax, randf() * zMax)
		randVec3.x = round(randVec3.x)
		randVec3.y = round(randVec3.y)
		randVec3.z = round(randVec3.z)
	else:
		randVec2 = Vector2(randf() * xMax, randf() * yMax)
		randVec2.x = round(randVec2.x)
		randVec2.y = round(randVec2.y)
	if isVector3:
		return Vector3(randVec3.x, randVec3.y, randVec3.z)
	else:
		return Vector2(randVec2.x, randVec2.y)
    