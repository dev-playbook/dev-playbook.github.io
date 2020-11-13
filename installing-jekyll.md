# Installing Jekyll With Docker

docker pull ubuntu

docker run -it --name my-ubuntu ubuntu

apt-get update
apt-get install ruby-dev
apt-get install rubygems
apt-get install gcc
apt-get install g++
apt-get install make
gem install jekyll bundler

ruby -v
gem -v
gcc -v
g++ -v
make -v
jekyll -v
bundler -v

apt install iproute2

exit

docker commit my-ubuntu jekyll-ubuntu

docker run -it --name my-jekyll -v "$(pwd):/usr/dev" -p 8181:4000 jekyll-ubuntu

jekyll new myblog

cd myblog

jekyll serve
