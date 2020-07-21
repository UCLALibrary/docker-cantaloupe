
package edu.ucla.library.iiif.cantaloupe;

import java.io.IOException;

import org.junit.Before;

import info.freelibrary.util.StringUtils;

/**
 * A base class for Cantaloupe integration tests.
 */
class AbstractCantaloupeIT {

    private static final String URL_PATTERN = "http://localhost:{}";

    private static final String DEFAULT_PORT = "8182";

    protected String myURL;

    protected int myPort;

    protected boolean hasKakaduInstalled;

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
