
package edu.ucla.library.iiif.cantaloupe;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.io.IOException;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.junit.Before;
import org.junit.Test;

import info.freelibrary.util.Logger;
import info.freelibrary.util.LoggerFactory;

/**
 * Tests the version of the running Cantaloupe server.
 */
public class VersionIT extends AbstractCantaloupeIT {

    private static final Logger LOGGER = LoggerFactory.getLogger(VersionIT.class, MessageCodes.BUNDLE);

    private Document myHTML;

    /**
     * Sets up the testing environment.
     */
    @Override
    @Before
    public void setUp() throws IOException {
        super.setUp();

        LOGGER.debug(MessageCodes.CAN_000, myURL);
        myHTML = Jsoup.connect(myURL).get();
    }

    /**
     * Confirm that the test instance's version matches the expected Cantaloupe version.
     */
    @Test
    public void testVersion() {
        final Element foundVersion = myHTML.selectFirst("#container h1 small");
        final String expectedVersion = System.getProperty(Constants.CANTALOUPE_VERSION);

        assertNotNull(LOGGER.getMessage(MessageCodes.CAN_003), expectedVersion);
        assertNotNull(LOGGER.getMessage(MessageCodes.CAN_002), foundVersion);

        if ("dev".equals(expectedVersion)) {
            assertEquals(LOGGER.getMessage(MessageCodes.CAN_001), "Unknown", foundVersion.text());
        } else {
            assertEquals(LOGGER.getMessage(MessageCodes.CAN_001), expectedVersion, foundVersion.text());
        }
    }

}
