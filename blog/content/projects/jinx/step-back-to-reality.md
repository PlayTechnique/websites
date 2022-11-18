---
title: "Step Back to Reality"
date: 2022-11-18T06:58:17-07:00
draft: false
---

Jinx and Jinkies are a dual project I started after I quit my last job. I was on a CI team there, and it had the most refined
workflow for using Jenkins that I've ever seen: end users would start dev versions of Jenkins on their laptops so they
could tinker and write jobs, and would submit those jobs for PR when they got them right, not before.

Because of this, the build servers didn't have that slew of dozens of failed jobs while someone was getting the build right.

It was all coordinated with a pretty straightforwards cli application that could start and stop the build container, and 
took care of ensuring new updates were retrieved and whatnot.

I thought we had (a) the best Jenkins installation and workflow in the world and (b) not quite what I wanted.

So, when I left I started writing what I thought that tooling should be. I always thought that we focused on a great
end-user experience, but could've done more to support our own development workflow, so I started out wanting to write
better dev tooling for creating a programatically defined instance of Jenkins.

Along the way, I've learned a few lessons, and I think I'm finally ready to take another crack at it.

The major lessons is: if you don't already know how to programatically configure Jenkins, it's hard to figure
out how to programatically configure Jenkins. So can I make that easier?

It turns out that yet another project generator seems like the place to start.
