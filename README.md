# Interactive 3D book ![Godot v3.2](https://img.shields.io/badge/godot-v3.2-%23478cbf)

![Interactive 3D book screenshot](resources/other/screenshot.png)

A simple 3D book with turning pages that displays the content of dynamic 2D scenes. Contains a working [Godot Engine](https://github.com/godotengine/godot) project and original [Blender](https://www.blender.org/) scene with an animated page.

## Manual

Use left and right arrows to turn the pages. The content is generated dynamically.

## Explanation

This example uses a 2D scene to generate the content of the page. It is later wrapped in a Viewport node, to turn that content into a texture. There are 6 viewports:
* current page (the one on the left)
* next page (the one on the right from the current page)
* 2 pages before the current page
* 2 pages after the next page

Additional viewports are used to generate the content of extra pages when turning. There are never more than 4 pages visible at the same time, but a total of 6 viewports allows the code to be a bit more consistent.

The example has both a Spatial node with 2 static pages (only left and right) and a Spatial node with 4 pages visible when turning (left, middle front, middle back, right). During the animation, the first node is hidden and the other is visible. When the animation ends, the first node becomes visible and the other is hidden.

Feel free to investigate the code and test how this example works. If you have any questions, don't hesitate to get in touch ;)

## Fonts

The `Tuffy.ttf` font was downloaded from [Public Domain Files](http://www.publicdomainfiles.com/show_file.php?id=13486218041168) and is in public domain.

## Books

The books used in this project are *Outer Space #1*, *Outer Space #17*, and *Outer Space #18*. They can be found on [Comic Book +](https://comicbookplus.com/?cid=1212) and are in public domain.
