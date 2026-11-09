class ImageLayer {

  PGraphics offScreenBuffer;
  PGraphics displayLayer;
  PImage    lastScreen;   // last frame's screen, fed back in: the loop

  int     startX = 900, startY = 360;   // stand-in mouse until it moves
  boolean mouseTouched = false;

  ImageLayer() {
    offScreenBuffer   = createGraphics(width, height, P2D);
    displayLayer      = createGraphics(width, height, P2D);
  }

  void ready() {
    // Use the mouse once it moves. Until then, start where the
    // feedback shows right away: a big box with a tunnel around it.
    if (mouseX != pmouseX || mouseY != pmouseY) mouseTouched = true;
    int mx = mouseTouched ? mouseX : startX;
    int my = mouseTouched ? mouseY : startY;

    background(0);

    // FEEDBACK: draw last frame back in, a bit bigger and a bit faded,
    // like a camera pointed at its own monitor
    if (lastScreen != null) {
      tint(255, 235);
      image(lastScreen, -6, -3, width + 12, height + 6);
      noTint();
    }

    // Draw to offScreenBuffer
    offScreenBuffer.beginDraw();
    offScreenBuffer.fill(0, 255, 0);
    offScreenBuffer.ellipse(mx, my, 60, 60);
    offScreenBuffer.fill(255, 0, 255, 50);
    offScreenBuffer.ellipse(width-mx, height-my, 60, 60);
    offScreenBuffer.endDraw();

    // Add buffer to displayLayer
    displayLayer.beginDraw();
    displayLayer.image(offScreenBuffer, 0, 0);
    displayLayer.fill(0, 0);                      // Draw edge around displayLayer PGraphic
    displayLayer.stroke(255, 0, 0, 50);           // Draw edge around displayLayer PGraphic
    displayLayer.rect(100, 100, mx, my);  // Draw edge around displayLayer PGraphic
    displayLayer.endDraw();

    // Show displayLayer
    image(displayLayer, 100, 100, mx, my);
    image(displayLayer, mx, my, 200, 200);

    // Grab what's on screen now, so next frame can draw it back in
    lastScreen = get();
  }
}
