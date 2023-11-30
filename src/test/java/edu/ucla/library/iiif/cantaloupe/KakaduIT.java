
package edu.ucla.library.iiif.cantaloupe;

import static org.junit.Assert.assertEquals;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

import javax.imageio.ImageIO;

import org.json.JSONObject;
import org.junit.Before;
import org.junit.Test;

import info.freelibrary.util.Logger;
import info.freelibrary.util.LoggerFactory;

/**
 * A test that confirms Cantaloupe's Kakadu configuration is working.
 */
public class KakaduIT extends AbstractCantaloupeIT {

    /** A test logger. */
    private static final Logger LOGGER = LoggerFactory.getLogger(KakaduIT.class, MessageCodes.BUNDLE);

    /**
     * Sets up the testing environment.
     */
    @Override
    @Before
    public void setUp() throws IOException {
        super.setUp();

        if (hasKakaduInstalled) {
            LOGGER.debug(MessageCodes.CAN_004);
        }
    }

    /**
     * Test that Kakadu can successfully return a JPEG 2000 image's info.json file.
     */
    @Test
    public void testKakaduJSON() throws MalformedURLException, IOException {
        if (hasKakaduInstalled && !isDevBuild) {
            final URL url = new URL(myURL + "/iiif/2/test.jp2");
            final JSONObject json;

            try (Scanner scanner = new Scanner(url.openStream(), StandardCharsets.UTF_8.toString())) {
                scanner.useDelimiter("\\A");
                json = new JSONObject(scanner.hasNext() ? scanner.next() : Constants.EMPTY);

                assertEquals(2000, json.getInt("width"));
                assertEquals(2000, json.getInt("height"));
            }
        } // else, we just ignore
    }

    /**
     * Test that Kakadu can successfully return a JPEG 2000 image.
     */
    @Test
    public void testKakaduImage() throws MalformedURLException, IOException {
        if (hasKakaduInstalled) {
            final BufferedImage image = ImageIO.read(new URL(myURL + "/iiif/2/test.jp2/full/full/0/default.jpg"));

            assertEquals(2000, image.getWidth());
            assertEquals(2000, image.getHeight());
        } // else, we just ignore
    }
}
