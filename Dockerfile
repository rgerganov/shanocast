FROM ubuntu:20.04
RUN apt-get update -y
RUN apt-get -y install libsdl2-2.0-0 ffmpeg libatomic1
COPY cast_receiver /root
WORKDIR /root
ENTRYPOINT ["/root/cast_receiver"]
