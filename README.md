Gwyn's Blog! This probably isn't super interesting to most people, but there are a few things to know.

First, the tooling is [Pelican](https://blog.getpelican.com) and docker. Pelican generates static HTML files for the blog from markdown 
files.

Docker provides an httpd container preconfigured to serve static html.

* To build, run Docker/build.sh. This will generate the html and copy it into a container.
* To run the blog (you have no reason to want to do this), use the run.sh script.