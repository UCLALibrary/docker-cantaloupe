
package edu.ucla.library.iiif.cantaloupe;

import static org.junit.Assert.*;

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
        final Element foundVersionElem = myHTML.selectFirst("#container h1 small");
        final String expectedVersion = System.getProperty(Constants.CANTALOUPE_VERSION);
        final String commitRef = System.getProperty(Constants.CANTALOUPE_COMMIT_REF);
        final String foundVersion;

        assertNotNull(LOGGER.getMessage(MessageCodes.CAN_003), expectedVersion);
        assertNotNull(LOGGER.getMessage(MessageCodes.CAN_002), foundVersionElem);

        foundVersion = foundVersionElem.text();

        if ("dev".equals(expectedVersion)) {
            if ("latest".equals(commitRef)) {
                assertTrue(LOGGER.getMessage(MessageCodes.CAN_001, foundVersion), foundVersion.contains("SNAPSHOT"));
            } // We skip if we're building from a commit hash; the version isn't really accurate in this case
        } else {
            assertEquals(LOGGER.getMessage(MessageCodes.CAN_001, foundVersion), expectedVersion, foundVersion);
        }
    }

}
