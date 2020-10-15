package my_plugins;

import ij.ImagePlus;
import ij.plugin.filter.GaussianBlur;
import ij.plugin.filter.PlugInFilter;
import ij.process.ByteProcessor;
import ij.process.ColorProcessor;
import ij.process.ImageProcessor;

/**
 * Example ImageJ Plugin that inverts an 8-bit grayscale image.
 * This file is part of the 'imagingbook' support suite. See
 * <a href = "http://imagingbook.com"> http://imagingbook.com</a>
 * for details and additional ImageJ resources.
 * 
 * @author W. Burger
 */
public class Demo_Plugin implements PlugInFilter {

	private static final double sigma = 2.0D;
	private static final double gamma = 2.5D;

	public int setup(String args, ImagePlus image) {
		return DOES_RGB + DOES_8G;
	}

	public void run(ImageProcessor ip) {
		if(ip instanceof ColorProcessor)
			sharpen_color(ip);
		if(ip instanceof ByteProcessor)
			sharpen_bw(ip);
	}

	private void sharpen_color(ImageProcessor ip){
		ImageProcessor ip_blurred = new ColorProcessor(ip.getWidth(), ip.getHeight());
		int[] rgb_pixels = (int[]) ip.getPixels();
		int[] blurred_pixels = (int[]) ip_blurred.getPixels();
		System.arraycopy(rgb_pixels, 0, blurred_pixels, 0, rgb_pixels.length);
		GaussianBlur gaussblur = new GaussianBlur();
		gaussblur.blurGaussian(ip_blurred, sigma);

		for (int i = 0; i < rgb_pixels.length; i++) {
			int r = (rgb_pixels[i] & 0xff0000) >> 16;
			int g = (rgb_pixels[i] & 0x00ff00) >> 8;
			int b = (rgb_pixels[i] & 0x0000ff);

			int r1 = (blurred_pixels[i] & 0xff0000) >> 16;
			int g1 = (blurred_pixels[i] & 0x00ff00) >> 8;
			int b1 = (blurred_pixels[i] & 0x0000ff);

			r1 = (int) (r + gamma * (r - r1) + 0.5);
			r1 = adjustBrightness(r1);

			g1 = (int) (g + gamma * (g - g1) + 0.5);
			g1 = adjustBrightness(g1);

			b1 = (int) (b + gamma * (b - b1) + 0.5);
			b1 = adjustBrightness(b1);

			blurred_pixels[i] = (((r1 & 0xff) << 16) | ((g1 & 0xff) << 8) | b1 & 0xff);
		}


		ImagePlus sharpened_image = new ImagePlus("Sharpened Image", ip_blurred);
		sharpened_image.show();

	}

	private void sharpen_bw(ImageProcessor ip){
		ImageProcessor ip_blurred = new ByteProcessor(ip.getWidth(), ip.getHeight());
		byte[] gray_pixels = (byte[]) ip.getPixels();
		byte[] blurred_pixels = (byte[]) ip_blurred.getPixels(); 

		System.arraycopy(gray_pixels, 0, blurred_pixels, 0, gray_pixels.length);

		GaussianBlur gaussblur = new GaussianBlur();
		gaussblur.blurGaussian(ip, sigma);

		for(int i = 0; i < gray_pixels.length; i++ ){
			int pixel = (int)((gray_pixels[i] & 0xff) + gamma * ((gray_pixels[i]& 0xff) - (blurred_pixels[i] & 0xff)) + 0.5);
			pixel = adjustBrightness(pixel);
			blurred_pixels[i] = (byte) pixel;
		}

		ImagePlus sharpened_image = new ImagePlus("Sharpened Image", ip_blurred);
		sharpened_image.show();
	}

	private int adjustBrightness(int x){
		if(x > 255) {
			return 255;
		}
		if(x < 0) {
			return 0;
		}
		return x;
	}


}
