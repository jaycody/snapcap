class ImageLayer {

  PGraphics offScreenBuffer;
  PGraphics displayLayer;

  ImageLayer() {
    offScreenBuffer   = createGraphics(width, height, P2D);
    displayLayer      = createGraphics(width, height, P2D);
  }

  void ready() {
    background(0);

    // Draw to offScreenBuffer
    offScreenBuffer.beginDraw();
    offScreenBuffer.fill(0, 255, 0);
    offScreenBuffer.ellipse(mouseX, mouseY, 60, 60);
    offScreenBuffer.fill(255, 0, 255, 50);
    offScreenBuffer.ellipse(width-mouseX, height-mouseY, 60, 60);
    offScreenBuffer.endDraw();

    // Add buffer to displayLayer
    displayLayer.beginDraw();
    displayLayer.image(offScreenBuffer, 0, 0);
    displayLayer.fill(0, 0);                      // Draw edge around displayLayer PGraphic
    displayLayer.stroke(255, 0, 0, 50);           // Draw edge around displayLayer PGraphic
    displayLayer.rect(100, 100, mouseX, mouseY);  // Draw edge around displayLayer PGraphic
    displayLayer.endDraw();

    // Show displayLayer
    image(displayLayer, 100, 100, mouseX, mouseY);
    image(displayLayer, mouseX, mouseY, 200, 200);
  }
}
