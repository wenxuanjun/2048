# Enable global variables in V
v := "v -enable-globals"

# Debug without bounds checking
run *flags:
	{{v}} -no-bounds-checking run . {{flags}}

# Play the game with GUI
play:
	{{v}} -no-bounds-checking run . -g -l

# Build the project
build:
	{{v}} -prod -skip-unused -no-bounds-checking -show-timings -cc gcc -cflags "-flto" .

# Debug with bounds checking
debug *flags:
	{{v}} run . {{flags}}

# Profiling the game
profile file="profile.txt":
	{{v}} -profile {{file}} -no-bounds-checking run . -a

# Strip the executable binary
strip:
	strip 2048*

# Use UPX to compress the executable
upx:
	upx --ultra-brute 2048*
