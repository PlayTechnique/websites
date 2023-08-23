---
title: "What is a Templ"
date: 2023-08-23T20:28:01-06:00
draft: false
---
I wrote myself a small tool for rendering go templates and cloning a github repo of those templates.
It's a nice little utility that I've been using daily since I wrote it, and I have ideas for new features,
but it isn't idiomatic go and has needed a rewrite.

I've heard ever since I was wee that you should write version 1, then throw it away. That's what I'm doing.

The first version was a beautiful mess of very procedural logic; this one is more leaning into interfaces and types,
and removing some of the fatter dependencies. Here's my thoughts, in an internet-friendly numbered list:

1. I thought "I should write a simple cli tool" and my second thought was "I should use subcommands". I stayed away from
Cobra and Viper", because I've found them pretty heavyweight in the past. I thought a lighter weight library like [subcommands](https://github.com/google/subcommands)
would be a nice replacement, but I came to realise that I'm writing something that does five things and subcommands 
are really heavy for that. I should think simpler. 

1. In version 0.0.* I decided to use logrus for all my messaging needs. It means I have error messages now that look like
this:
```bash
; templ
INFO[0000] Did not find </Users/gwyn/.config/templ> directory. Creating... 
```
I really don't enjoy the boilerplate, especially in the face of an error:
```bash
 ; TEMPL_LOG_LEVEL=debug templ render fetch=roflcopter
INFO[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/main.go:51 main.main() Starting templ                               
DEBU[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/main.go:93 main.getTemplatesDirectory() Did not find TEMPL_DIR. Switching to default templates directory. 
INFO[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/main.go:104 main.getTemplatesDirectory() Did not find </Users/gwyn/.config/templ> directory. Creating... 
DEBU[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/cmds/templcommands/finder.go:21 github.com/gwynforthewyn/templ/cmds/templcommands.findFilesByName() Outside filepath.Walk function names: [fetch] 
DEBU[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/cmds/templcommands/finder.go:28 github.com/gwynforthewyn/templ/cmds/templcommands.findFilesByName.func1() Inside filepath.Walk function names: [fetch] 
DEBU[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/cmds/templcommands/finder.go:32 github.com/gwynforthewyn/templ/cmds/templcommands.findFilesByName.func1() name is <fetch> path is </Users/gwyn/.config/templ> 
DEBU[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/cmds/templcommands/render.go:123 github.com/gwynforthewyn/templ/cmds/templcommands.RenderCommand.Execute() Found templateFilePaths,[]                   
DEBU[0000]/Users/gwyn/go/pkg/mod/github.com/gwynforthewyn/templ@v0.0.0-20230731192531-9bb868be69e0/cmds/templcommands/render.go:155 github.com/gwynforthewyn/templ/cmds/templcommands.render() filesInArgs: []                              
```
I was looking for line numbers associated with my errors; I got an unreadable mess. I'm still not convinced I know how 
to handle error messaging and information messaging, but I do know the above cannot be the right solution. I'm not sure
if I should remove logrus, figure out log formatting better, or what. I do know I'd prefer to use the standard library
over a third party dependency, and now we have `slog`.

1. I tried four or five types of syntax for the combination of a template and config file that hydrates the variables;
I think what I ended up with `templ render template.abc=config-file.yaml` is lightweight syntax, but that piping would be
even better `templ template.abc` can dump to stdout by default and `templ template.abc | templ var1=foo var2=bar` looks
pretty hot.

1. A big rewrite takes time and effort. I'm frustrated by not adding new features, even as I admire how much more extensible
the new implementation is. For example, version 0.0.* couldn't support anything other than github URLs; version 0.1.* 
already supports more kinds of repository than that, and added new ones involves implementing an interface which is lovely.

1. Config elements are surprisingly behavioural. There's an environment variable, and having to figure out if we're using
the default or the env var and satisfying pre- and post- conditions is all wrapped up in there.
