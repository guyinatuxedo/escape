#Import the pwnableharness docker image from https://hub.docker.com/r/c0deh4cker/pwnableharness/
FROM c0deh4cker/pwnableharness

#Specify the maintainer of the challenge
MAINTAINER guyinatuxedo <guy@tux.com>

#Import the Flag.txt file
ARG FLAG=flag.txt
ENV FLAG=$FLAG

#Copy over the flag.txt file
copy $FLAG flag.txt

#Set permissions for the flag.txt file
RUN chown root:$RUNTIME_NAME flag.txt && chmod 0640 flag.txt

#Define the port which the docker container will be accessible over
EXPOSE 41236 
