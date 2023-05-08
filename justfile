# Debug without bounds checking
run flags="":
	v -no-bounds-checking run . {{flags}}

# Build the project
build:
	v -prod -skip-unused -no-bounds-checking -show-timings .

# Debug with bounds checking
debug flags="":
	v run . {{flags}}

# Strip the executable binary
strip:
	strip 2048*

# Use UPX to compress the executable
upx:
	upx --ultra-brute 2048*
