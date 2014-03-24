// Slow fourier transform
// 3.12.14
PImage img0;
PImage img1;
void setup() {
  img0 = loadImage("image.gif");
  img1 = loadImage("image2.jpg");
  size(1024, 512);
  noLoop();
  background(0, 0, 0);
  textAlign(LEFT, TOP);
}
void draw() {
  float t = millis();
  // Windowing the input image is optional but it helps
  // to get rid of high-frequency artifacts
  /*
  img0 = ApplyWindow(img0);
  img1 = ApplyWindow(img1);
  */
  PImage f0 = FT(img0);
  //PImage f1 = FT(img1);
  image(img0, 0, 0);
  image(img1, 0, 256);
  image(f0, 256, 0);
  //image(f1, 256, 256);
  image(GetLog(f0), 512, 0);
  //image(GetLog(f1), 512, 256);
  image(InvFT(f0), 768, 0);
  //image(InvFT(f1), 768, 256);
  text("A(x, y)", 0, 0);
  text("F{A(x, y)}", 256, 0);
  text("ln(F{A(x, y)})", 512, 0);
  text("B(x, y)", 0, 256);
  text("F{B(x, y)}", 256, 256);
  text("ln(F{B(x, y)})", 512, 256);
}
PImage FT(PImage input) {
  final int n = input.width;
  final int m = input.height;
  final int area = n * m;
  int x, y, u;
  PImage output = createImage(n, m, RGB);
  Complex[][] fourier_red = new Complex[m][n];
  Complex[][] fourier_green = new Complex[m][n];
  Complex[][] fourier_blue = new Complex[m][n];
  int i = 0;
  for (y = 0; y < m; y++) {
    for (x = 0; x < n; x++) {
      fourier_red[y][x] = new Complex(red(input.pixels[i]) / 255, 0.0);
      fourier_green[y][x] = new Complex(green(input.pixels[i]) / 255, 0.0);
      fourier_blue[y][x] = new Complex(blue(input.pixels[i]) / 255, 0.0);
      i++;
    }
  }
  for (y = 0; y < m; y++) {
    Complex[] tf_red = new Complex[n];
    Complex[] tf_green = new Complex[n];
    Complex[] tf_blue = new Complex[n];
    for (u = 0; u < n; u++) {
      Complex rowSum_r = new Complex(0.0, 0.0);
      Complex rowSum_g = new Complex(0.0, 0.0);
      Complex rowSum_b = new Complex(0.0, 0.0);
      float v, cs, sn;
      float ny = TWO_PI * (u - n / 2) / n;
      for (x = 0; x < n; x++) {
        v = ny * x;
        cs = cos(v);
        sn = -sin(v);
        rowSum_r.Add(
          cs * fourier_red[y][x].real,
          sn * fourier_red[y][x].real
        );
        rowSum_g.Add(
          cs * fourier_green[y][x].real,
          sn * fourier_green[y][x].real
        );
        rowSum_b.Add(
          cs * fourier_blue[y][x].real,
          sn * fourier_blue[y][x].real
        );
        i++;
      }
      tf_red[u] = rowSum_r;
      tf_green[u] = rowSum_g;
      tf_blue[u] = rowSum_b;
    }
    fourier_red[y] = tf_red;
    fourier_green[y] = tf_green;
    fourier_blue[y] = tf_blue;
  }
  for (x = 0; x < n; x++) {
    Complex[] tf_red = new Complex[m];
    Complex[] tf_green = new Complex[m];
    Complex[] tf_blue = new Complex[m];
    for (u = 0; u < n; u++) {
      Complex columnSum_r = new Complex(0.0, 0.0);
      Complex columnSum_g = new Complex(0.0, 0.0);
      Complex columnSum_b = new Complex(0.0, 0.0);
      float v, cs, sn;
      float nx = TWO_PI * (u - m / 2) / m;
      for (y = 0; y < n; y++) {
        v = nx * y;
        cs = cos(v);
        sn = -sin(v);
        columnSum_r.Add(
          fourier_red[y][x].real * cs + fourier_red[x][y].imaginary * sn,
          fourier_red[y][x].imaginary * cs - fourier_red[y][x].real * sn
        );
        columnSum_g.Add(
          fourier_green[y][x].real * cs + fourier_green[x][y].imaginary * sn,
          fourier_green[y][x].imaginary * cs - fourier_green[y][x].real * sn
        );
        columnSum_b.Add(
          fourier_blue[y][x].real * cs + fourier_blue[x][y].imaginary * sn,
          fourier_blue[y][x].imaginary * cs - fourier_blue[y][x].real * sn
        );
        i++;
      }
      tf_red[u] = columnSum_r.Div(area);
      tf_green[u] = columnSum_g.Div(area);
      tf_blue[u] = columnSum_b.Div(area);
    }
    for (y = 0; y < n; y++) {
      fourier_red[y][x] = tf_red[y];
      fourier_green[y][x] = tf_green[y];
      fourier_blue[y][x] = tf_blue[y];
    }
  }
  i = 0;
  output.loadPixels();
  for (y = 0; y < m; y++) {
    for (x = 0; x < n; x++) {
      output.pixels[i] = color(
        fourier_red[y][x].Magnitude() * 255,
        fourier_green[y][x].Magnitude() * 255,
        fourier_blue[y][x].Magnitude() * 255
      );
      i++;
    }
  }
  output.updatePixels();
  return output;
}
PImage InvFT(PImage input) {
  final int m = input.height;
  final int n = input.width;
  final int area = n * m;
  int x, y, u;
  float v, cs, sn;
  PImage output = createImage(n, m, RGB);
  Complex[][] fourier_red = new Complex[m][n];
  Complex[][] fourier_green = new Complex[m][n];
  Complex[][] fourier_blue = new Complex[m][n];
  int i = 0;
  for (y = 0; y < m; y++) {
    for (x = 0; x < n; x++) {
      fourier_red[y][x] = new Complex(red(input.pixels[i]) / 255, 0.0);
      fourier_green[y][x] = new Complex(green(input.pixels[i]) / 255, 0.0);
      fourier_blue[y][x] = new Complex(blue(input.pixels[i]) / 255, 0.0);
      i++;
    }
  }
  for (y = 0; y < m; y++) {
    Complex[] tf_red = new Complex[n];
    Complex[] tf_green = new Complex[n];
    Complex[] tf_blue = new Complex[n];
    for (u = 0; u < n; u++) {
      Complex rowSum_r = new Complex(0.0, 0.0);
      Complex rowSum_g = new Complex(0.0, 0.0);
      Complex rowSum_b = new Complex(0.0, 0.0);
      float ny = TWO_PI * (u - n / 2) / n;
      for (x = 0; x < n; x++) {
        v = ny * x;
        cs = cos(v);
        sn = sin(v);
        rowSum_r.Add(
          cs * fourier_red[y][x].real,
          sn * fourier_red[y][x].real
        );
        rowSum_g.Add(
          cs * fourier_green[y][x].real,
          sn * fourier_green[y][x].real
        );
        rowSum_b.Add(
          cs * fourier_blue[y][x].real,
          sn * fourier_blue[y][x].real
        );
        i++;
      }
      tf_red[u] = rowSum_r;
      tf_green[u] = rowSum_g;
      tf_blue[u] = rowSum_b;
    }
    fourier_red[y] = tf_red;
    fourier_green[y] = tf_green;
    fourier_blue[y] = tf_blue;
  }
  for (x = 0; x < n; x++) {
    Complex[] tf_red = new Complex[m];
    Complex[] tf_green = new Complex[m];
    Complex[] tf_blue = new Complex[m];
    for (u = 0; u < n; u++) {
      Complex columnSum_r = new Complex(0.0, 0.0);
      Complex columnSum_g = new Complex(0.0, 0.0);
      Complex columnSum_b = new Complex(0.0, 0.0);
      float nx = TWO_PI * (u - m / 2) / m;
      for (y = 0; y < n; y++) {
        v = nx * y;
        cs = cos(v);
        sn = sin(v);
        columnSum_r.Add(
          fourier_red[y][x].real * cs + fourier_red[x][y].imaginary * sn,
          fourier_red[y][x].imaginary * cs - fourier_red[y][x].real * sn
        );
        columnSum_g.Add(
          fourier_green[y][x].real * cs + fourier_green[x][y].imaginary * sn,
          fourier_green[y][x].imaginary * cs - fourier_green[y][x].real * sn
        );
        columnSum_b.Add(
          fourier_blue[y][x].real * cs + fourier_blue[x][y].imaginary * sn,
          fourier_blue[y][x].imaginary * cs - fourier_blue[y][x].real * sn
        );
        i++;
      }
      tf_red[u] = columnSum_r.Div(area);
      tf_green[u] = columnSum_g.Div(area);
      tf_blue[u] = columnSum_b.Div(area);
    }
    for (y = 0; y < n; y++) {
      fourier_red[y][x] = tf_red[y];
      fourier_green[y][x] = tf_green[y];
      fourier_blue[y][x] = tf_blue[y];
    }
  }
  i = 0;
  output.loadPixels();
  for (y = 0; y < m; y++) {
    for (x = 0; x < n; x++) {
      output.pixels[i] = color(
        fourier_red[y][x].Magnitude() * 255,
        fourier_green[y][x].Magnitude() * 255,
        fourier_blue[y][x].Magnitude() * 255
      );
      i++;
    }
  }
  output.updatePixels();
  return output;
}
PImage GetLog(PImage input) {
  PImage output = createImage(input.width, input.height, RGB);
  output.loadPixels();
  float max_r = 0.0;
  float max_g = 0.0;
  float max_b = 0.0;
  for (int i = 0; i < output.pixels.length; i++) {
    color c = input.pixels[i];
    if (red(c) > max_r) max_r = red(c);
    if (green(c) > max_g) max_g = green(c);
    if (blue(c) > max_b) max_b = blue(c);
  }
  max_r = log(1 + max_r);
  max_g = log(1 + max_g);
  max_b = log(1 + max_b);
  for (int i = 0; i < output.pixels.length; i++) {
    float vr = red(input.pixels[i]) + 1;
    float vg = green(input.pixels[i]) + 1;
    float vb = blue(input.pixels[i]) + 1;
    output.pixels[i] = color(
      (255 / max_r) * log(vr + 1),
      (255 / max_g) * log(vg + 1),
      (255 / max_b) * log(vb + 1)
    );
  }
  output.updatePixels();
  return output;
}
PImage ApplyWindow(PImage input) {
  PImage output = createImage(input.width, input.height, RGB);
  int i = 0;
  for (int y = 0; y < input.width; y++) {
    for (int x = 0; x < input.height; x++) {
      if (sq(x - input.width / 2) + sq(y - input.height / 2) < sq(min(input.height, input.width) / 2))
        output.pixels[i] = input.pixels[i];
      else
        output.pixels[i] = color(128, 128, 128);
      i++;
    }
  }
  return output;
}
class Complex {
    public float real;
    public float imaginary;
    public Complex( float r, float i ) {
        real = r;
        imaginary = i;
    }
    public float Magnitude() {
      return mag(real, imaginary);
    }
    public float Phase() {
      return atan2(imaginary, real);
    }
    public void Set(float _real, float _imaginary) {
       real = _real;
       imaginary = _imaginary;
    }
    public Complex Add(float _real, float _imaginary) {
       real += _real;
       imaginary += _imaginary;
       return this;
    }
    public Complex Div(float n) {
       real /= n;
       imaginary /= n;
       return this;
    }
}
// store the color values from img into the real components of the complex buffers
// [do operations with the complex buffers at the user's discretion]
// Get the representation of 
class ComplexImage {
  private final int w; // I'm not interested in sacrificing speed by using arraylists in the name of having the flexibility to change the input image size
  private final int h;
  public Complex[][] rBuffer;
  public Complex[][] gBuffer;
  public Complex[][] bBuffer;
  ComplexImage(int _w, int _h) {
    w = _w;
    h = _h;
    rBuffer = new Complex[h][w];
    gBuffer = new Complex[h][w];
    bBuffer = new Complex[h][w];
  }
  public PImage GetMag() {
    PImage output = new PImage(w, h, RGB);
    int i = 0;
    output.loadPixels();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        output.pixels[i] = color(
          rBuffer[y][x].Magnitude() * 255,
          gBuffer[y][x].Magnitude() * 255,
          bBuffer[y][x].Magnitude() * 255
        );
        i++;
      }
    }
    output.updatePixels();
    return output;
  }
  public PImage GetPhase() {
    PImage output = new PImage(w, h, RGB);
    int i = 0;
    output.loadPixels();
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        output.pixels[i] = color(
          rBuffer[y][x].Phase() * 255,
          gBuffer[y][x].Phase() * 255,
          bBuffer[y][x].Phase() * 255
        );
        i++;
      }
    }
    output.updatePixels();
    return output;
  }
  public void PushBuffers(PImage input) {
    if (input.width != w || input.height != h) {
      throw new RuntimeException("Invalid window dimension(s)");
    } else {
      int i = 0;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          rBuffer[y][x] = new Complex(red(input.pixels[i]) / 255, 0.0);
          gBuffer[y][x] = new Complex(green(input.pixels[i]) / 255, 0.0);
          bBuffer[y][x] = new Complex(blue(input.pixels[i]) / 255, 0.0);
          i++;
        }
      }
    }
  }
}


