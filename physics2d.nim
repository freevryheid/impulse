##    Copyright (c) 2013 Randy Gaul http://RandyGaul.net
##
##    This software is provided 'as-is', without any express or implied
##    warranty. In no event will the authors be held liable for any damages
##    arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose,
##    including commercial applications, and to alter it and redistribute it
##    freely, subject to the following restrictions:
##      1. The origin of this software must not be misrepresented; you must not
##         claim that you wrote the original software. If you use this software
##         in a product, an acknowledgment in the product documentation would be
##         appreciated but is not required.
##      2. Altered source versions must be plainly marked as such, and must not be
##         misrepresented as being the original software.
##      3. This notice may not be removed or altered from any source distribution.
##
##    Port to Nim by Matic Kukovec https://github.com/matkuki/Nim-Impulse-Engine

import
  # os,
  # strutils,
  # times,
  math,
  random,
  basic2d,
  # ie_math,
  shapes,
  manifold,
  scene,
  sdl2,
  sdl2/gfx,
  opengl,
  glu

const
  WIDTH = 800
  HEIGHT = 600
  WINDOW_SIZE = (w: WIDTH, h: HEIGHT)

var
  run = true
  centerCircle = newCircle(5.0f)
  mainScene = newScene(10)
  bodyCounter: int = 0

proc initOpenGL() =
  loadExtensions()
  glMatrixMode(GL_PROJECTION)
  glPushMatrix()
  glLoadIdentity()
  gluOrtho2D(0, WINDOW_SIZE.w/10, WINDOW_SIZE.h/10, 0)
  glMatrixMode(GL_MODELVIEW)
  glPushMatrix()
  glLoadIdentity()

proc createRandomPoly(x,y: float) =
  # Create random polygon
  var
      poly: Polygon = newPolygon()
      # count: int = int(ie_math.random(3, MaxPolyVertexCount))
      count = random(3..MaxPolyVertexCount)
      vertices: array[MaxPolyVertexCount, Vector2d]
      e = random(5.0f) + 5.0f
      b: Body
  for i in 0..vertices.high:
      vertices[i].set(random(2*e)-e, random(2*e)-e)
  poly.set(vertices, count)
  b = mainScene.add(poly, x/10.0f, y/10.0f)
  b.setOrient(random(2*PI)-PI)
  b.restitution = 0.2f
  b.dynamicFriction = 0.2f
  b.staticFriction = 0.4f
  echo "Polygon added"
  bodycounter += 1
  echo "Total number of bodies:", bodycounter

proc createRandomCircle(x,y: float) =
  # Create random circle
  var
      c: Circle = newCircle(random(2.0f)+1.0f)
  discard mainScene.add(c, x/10.0f, y/10.0f)
  echo "Circle added"
  bodycounter += 1
  echo "Total number of bodies:", bodycounter

proc physicsLoop(dt: float) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  mainScene.step(dt)
  mainScene.render()

# Initialize SDL2
discard sdl2.init(INIT_VIDEO)
# Initialize the main window
let win = createWindow(
  "Physics",
  sdl2.SDL_WINDOWPOS_CENTERED, sdl2.SDL_WINDOWPOS_CENTERED,
  WIDTH, HEIGHT,
  SDL_WINDOW_OPENGL)

# Set up event handlers, context and openGL
discard win.glCreateContext()
var
  evt = sdl2.defaultEvent
  fps: FpsManager
initOpenGL()

# Initialize static(immovable) objects in the scene
var b: Body
# Middle circle
b = mainScene.add(centerCircle, 40.0f, 40.0)
b.setStatic()
# Bottom platform
var poly: Polygon = newPolygon()
poly.setBox(30.0f, 1.0f)
b = mainScene.add(poly, 40.0f, 55.0f)
b.setStatic()
b.setOrient(0)
# Left wall
poly = newPolygon()
poly.setBox(1.0f, 5.0f)
b = mainScene.add(poly, 11.0f, 49.0f)
b.setStatic()
b.setOrient(0)
# Right wall
poly = newPolygon()
poly.setBox(1.0f, 5.0f)
b = mainScene.add(poly, 69.0f, 49.0f)
b.setStatic()
b.setOrient(0)

# Main loop
while run:
  while pollEvent(evt):
    case evt.kind
    of QuitEvent:
      run = false
    of KeyDown:
      if evt.key.keysym.sym == K_ESCAPE:
        run = false
    of MouseButtonDown:
      if evt.button.button == BUTTON_LEFT:
        createRandomPoly(float(evt.button.x),float(evt.button.y))
      if evt.button.button == BUTTON_RIGHT:
        createRandomCircle(float(evt.button.x),float(evt.button.y))
    else: discard
  let dt = fps.getFramerate() / 1000
  physicsLoop(dt)
  win.glSwapWindow()
  fps.delay

# Cleanup everything
win.destroy()
