
package edu.ucla.library.iiif.cantaloupe;

/**
 * A collection of constant values used in testing Cantaloupe.
 */
public final class Constants {

    /** The randomly selected port at which Cantaloupe is run. */
    public static final String PORT = "http.port";

    /** The version of Cantaloupe that's being tested. */
    public static final String CANTALOUPE_VERSION = "cantaloupe.version";

    /** The Cantaloupe commit hash that's being tested. */
    public static final String CANTALOUPE_COMMIT_REF = "cantaloupe.commit.ref";

    /** The version of Kakadu that's being tested. */
    public static final String KAKADU_VERSION = "kakadu.version";

    /** A flag to indicate we want to build a snapshot build from the 5.x line. */
    public static final String DEV_BUILD = "devBuild";

    /** A constant representing an empty string. */
    public static final String EMPTY = "";

    /**
     * Creates a new constants class.
     */
    private Constants() {
        // This is intentionally left empty.
    }
}
