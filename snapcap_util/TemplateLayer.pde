class TemplateLayer {

  PGraphics makePixelsClear;
  PGraphics buffer;

  TemplateLayer() {
    makePixelsClear  = createGraphics(width, height, P2D);
    buffer           = createGraphics(width, height, P2D);
  }

  void ready() {
    //float r = random(1);
    background(0);
    //fill(180);
    //stroke(0,50);
    //ellipse(mouseX, mouseY, 360, 360);

    // Draw to Off-screen PGraphic
    makePixelsClear.beginDraw();
    makePixelsClear.fill(0, 255, 0);
    makePixelsClear.ellipse(mouseX, mouseY, 60, 60);
    makePixelsClear.fill(255, 0, 255, 50);
    makePixelsClear.ellipse(width-mouseX, height-mouseY, 60, 60);
    makePixelsClear.endDraw();

    // Draw the off-screen PGraphic to buffer
    buffer.beginDraw();
    buffer.image(makePixelsClear, 0, 0);
    buffer.fill(0, 0);                      // Draw edge around buffer PGraphic
    buffer.stroke(255, 0, 0, 50);           // Draw edge around buffer PGraphic
    buffer.rect(100, 100, mouseX, mouseY);  // Draw edge around buffer PGraphic
    buffer.endDraw();

    // Draw buffers to screen
    image(buffer, 100, 100, mouseX, mouseY);
    image(buffer, mouseX, mouseY, 200, 200);
  }
}
