# Debug without bounds checking
run flags="":
	v -no-bounds-checking run . {{flags}}

# Build the project
build:
	v -prod -skip-unused -no-bounds-checking -show-timings .

# Debug with bounds checking
debug flags="":
	v run . {{flags}}

# Profiling the game
profile file="profile.txt":
	v -profile {{file}} -no-bounds-checking run . -a

# Strip the executable binary
strip:
	strip 2048*

# Use UPX to compress the executable
upx:
	upx --ultra-brute 2048*
