#Specify the binary which will be compiled
TARGET := b0

#Specify the Docker Image which this will be running as
DOCKER_IMAGE := guyinatuxedo/b0

#Specify additional files that will be loaded into the docker container
FLAG := $(patsunst $(DIR)/%,%,$(wildcard $(DIR)/flag.txt))
ARG_FLAG := $(if $(FLAG),FLAG=$(FLAG))
DOCKER_BUILD_ARGS := $(ARG_FLAG)

#Specify the port which the challenge will be running on
DOCKER_PORTS := 41236

#Specify that the Docker Container should be read only
DOCKER_RUN_ARGS := --read-only

#Define the stack to be NX (non-executable)
b0_NX := TRUE
