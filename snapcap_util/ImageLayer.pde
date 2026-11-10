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
    layerCount = 0;

    // Use the mouse once it moves. Until then, start where the
    // feedback shows right away: a big box with a tunnel around it.
    if (mouseX != pmouseX || mouseY != pmouseY) mouseTouched = true;
    int mx = mouseTouched ? mouseX : startX;
    int my = mouseTouched ? mouseY : startY;

    background(0);

    // FEEDBACK: draw last frame back in, a bit bigger and a bit faded,
    // like a camera pointed at its own monitor
    if (lastScreen != null) {
      tint(255, 135);
      layer(lastScreen, -6, -3, width + 12, height + 6);
      layer(lastScreen, 100, 100, my, mx);
      layer(lastScreen, width -100, height - 100, mx, my);
      noTint();
    }

    // Draw to offScreenBuffer
    offScreenBuffer.beginDraw();
    offScreenBuffer.fill(0, 255, 0);
    offScreenBuffer.ellipse(mx, my, 60, 60);
    offScreenBuffer.fill(255, 0, 255, 50);
    offScreenBuffer.ellipse(width-mx, height-my, 60, 60);
    offScreenBuffer.ellipse(mx-(width/2), my-(height/2), 40, 40);
    offScreenBuffer.endDraw();

    // Add buffer to displayLayer
    displayLayer.beginDraw();
    displayLayer.image(offScreenBuffer, 0, 0);
    displayLayer.fill(0, 0);                      // Draw edge around displayLayer PGraphic
    displayLayer.stroke(255, 0, 0, 50);           // Draw edge around displayLayer PGraphic
    displayLayer.rect(100, 100, mx, my);  // Draw edge around displayLayer PGraphic
    displayLayer.endDraw();

    // Show displayLayer
    layer(displayLayer, 100, 100, mx, my);
    layer(displayLayer, 300,300, (width-(mx/2)), height-(my/2));
    layer(displayLayer, (width-(mx)), height-(my),500,500);
    layer(displayLayer, 200, 200, mx-(width), my-(height));
    layer(displayLayer, mx, my, 200, 200);

// FEEDBACK: draw last frame back in, a bit bigger and a bit faded,
    // like a camera pointed at its own monitor
    if (lastScreen != null) {
      tint(255, 133);
      layer(lastScreen, mx/8, my/8, width -100, height - 100);
      layer(lastScreen, width -100, height - 100, width, my-(height));
      noTint();
    }

    // Grab what's on screen now, so next frame can draw it back in
    lastScreen = get();
    layer(displayLayer, (width-(mx)), height-(my),500,500);
    layer(lastScreen, mx/8, my/8, width -100, height - 100);

    // Number every layer on screen, 1 = closest to you. Drawn last and
    // after get(), so the numbers never feed back into the loop.
    if (showLabels) drawLabels();

  }

  /*//////////////////////////////////////////////////
   LAYER LABELS ('l' shows or hides them)
   layer() works like image(), and also remembers where each image
   landed. Each tag shows the layer number, then the x, y, w, h it was
   drawn with. The numbers count from the top: 1 is the last image
   drawn, the one closest to you. They update on their own when you
   add, remove or reorder layers. */
  boolean showLabels = true;
  int     layerCount = 0;
  float[][] layerRects = new float[64][8];   // where it landed, then x, y, w, h as given

  void layer(PImage img, float x, float y, float w, float h) {
    image(img, x, y, w, h);
    if (layerCount < layerRects.length) {
      // a negative width or height flips the image: find its real corner
      layerRects[layerCount][0] = min(x, x + w);
      layerRects[layerCount][1] = min(y, y + h);
      layerRects[layerCount][2] = abs(w);
      layerRects[layerCount][3] = abs(h);
      layerRects[layerCount][4] = x;
      layerRects[layerCount][5] = y;
      layerRects[layerCount][6] = w;
      layerRects[layerCount][7] = h;
    }
    layerCount++;
  }

  void drawLabels() {
    int shown = min(layerCount, layerRects.length);
    pushStyle();
    textSize(12);
    textAlign(LEFT, TOP);
    float[][] placed = new float[shown][];  // tags already drawn, to avoid stacking
    // Top layer first, so 1 gets the corner and lower layers move aside.
    for (int i = shown - 1; i >= 0; i--) {
      int    n = layerCount - i;            // 1 = drawn last = on top
      float[] r = layerRects[i];
      boolean onScreen = r[0] < width && r[1] < height && r[0] + r[2] > 0 && r[1] + r[3] > 0;
      String tag = n + "   x " + round(r[4]) + "  y " + round(r[5])
        + "  w " + round(r[6]) + "  h " + round(r[7]) + (onScreen ? "" : "  (off)");
      float  tw  = textWidth(tag) + 6;
      // pin the tag inside the window, even when the layer runs off it
      float tx = constrain(r[0] + 4, 2, width - tw - 2);
      float ty = constrain(r[1] + 4, 30, height - 18);
      // layers sharing a corner: slide right (or down) past earlier tags
      for (boolean moved = true; moved; ) {
        moved = false;
        for (float[] p : placed) {
          if (p != null && tx < p[0] + p[2] + 2 && tx + tw > p[0] - 2 && abs(ty - p[1]) < 17) {
            tx = p[0] + p[2] + 12;
            if (tx + tw > width - 2) {          // no room: next row, up if near the bottom
              tx = constrain(r[0] + 4, 2, width - tw - 2);
              ty += (ty > height - 40) ? -17 : 17;
            }
            moved = true;
          }
        }
      }
      placed[i] = new float[] { tx, ty, tw };
      noFill();
      stroke(255, 255, 0, 90);
      if (onScreen) rect(r[0], r[1], r[2], r[3]);
      noStroke();
      fill(0, 190);
      rect(tx - 3, ty - 1, tw, 16);
      fill(255, 255, 0);
      text(tag, tx, ty);
    }
    popStyle();
  }
}
