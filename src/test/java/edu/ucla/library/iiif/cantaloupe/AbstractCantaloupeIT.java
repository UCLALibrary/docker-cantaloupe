
package edu.ucla.library.iiif.cantaloupe;

import java.io.IOException;

import org.junit.Before;

import info.freelibrary.util.StringUtils;

/**
 * A base class for Cantaloupe integration tests.
 */
class AbstractCantaloupeIT {

    /** A URL pattern constant. */
    private static final String URL_PATTERN = "http://localhost:{}";

    /** A default port constant. */
    private static final String DEFAULT_PORT = "8182";

    /** The URL being tested. */
    protected String myURL;

    /** The port being tested. */
    protected int myPort;

    /** Whether the test system has Kakadu installed. */
    protected boolean hasKakaduInstalled;

    /** Whether the test is running in a development environment. */
    protected boolean isDevBuild;

    /**
     * Sets up the testing environment.
     *
     * @throws IOException If there is trouble reading or writing test data
     */
    @Before
    public void setUp() throws IOException {
        myPort = Integer.parseInt(System.getProperty(Constants.PORT, DEFAULT_PORT));
        myURL = StringUtils.format(URL_PATTERN, myPort);

        if (System.getProperty(Constants.KAKADU_VERSION) != null) {
            hasKakaduInstalled = true;
        }

        if (System.getProperty(Constants.DEV_BUILD) != null) {
            isDevBuild = true;
        }
    }

}
