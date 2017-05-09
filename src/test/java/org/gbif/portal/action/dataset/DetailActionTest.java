package org.gbif.portal.action.dataset;

import org.junit.Test;

import static junit.framework.Assert.assertEquals;

public class DetailActionTest {

    @Test
    public void makeCountryLinks() {
        String c = "/country/";

        assertEquals("<a href='/country/ES'>Spain</a>", DetailAction.makeCountryLinks(c, "Spain"));
        assertEquals("<a href='/country/ES'>SpAiN</a>", DetailAction.makeCountryLinks(c, "SpAiN"));

        assertEquals("<a href='/country/ES'>Spain</a>, <a href='/country/PT'>Portugal</a> andd <a href='/country/AD'>Andorra</a>.", DetailAction.makeCountryLinks(c, "Spain, Portugal andd Andorra."));

        assertEquals("<a href='/country/IM'>Isle of Man</a>", DetailAction.makeCountryLinks(c, "Isle of Man"));
        assertEquals("Isle of Many Things", DetailAction.makeCountryLinks(c, "Isle of Many Things"));

        assertEquals("<a href='/country/GW'>Guinea-Bissau</a>", DetailAction.makeCountryLinks(c, "Guinea-Bissau"));
        assertEquals("<a href='/country/GN'>Guinea</a>", DetailAction.makeCountryLinks(c, "Guinea"));

        assertEquals("<a href='/country/CG'>Congo</a>.", DetailAction.makeCountryLinks(c, "Congo."));
        assertEquals("<a href='/country/CD'>DR Congo</a>", DetailAction.makeCountryLinks(c, "DR Congo"));

        assertEquals("<a href='/country/US'>United States</a>", DetailAction.makeCountryLinks(c, "United States"));
        assertEquals("<a href='/country/US'>United States of America</a>", DetailAction.makeCountryLinks(c, "United States of America"));
        assertEquals("<a href='/country/US'>USA</a>", DetailAction.makeCountryLinks(c, "USA"));
        //the last dot of U.S.A. will be outside the <a> tag
        assertEquals("in the <a href='/country/US'>U.S.A</a>. ", DetailAction.makeCountryLinks(c, "in the U.S.A. "));
        //ensure dots are escaped otherwise Ursua will match u.s.a.
        assertEquals("Ursua", DetailAction.makeCountryLinks(c, "Ursua"));
        assertEquals("Matching US would also match us.", DetailAction.makeCountryLinks(c, "Matching US would also match us."));
        assertEquals("<a href='/country/VI'>US Virgin Islands</a>", DetailAction.makeCountryLinks(c, "US Virgin Islands"));

        String longText   = "from Angola J.M. Antunes...; L.A. Grandvaux Barbosa, from Cape Verde, Angola e Mozambique; J. Espírito Santo, from S. Tomé and Príncipe, and Guinea-Bissau;";
        String longResult = "from <a href='/country/AO'>Angola</a> J.M. Antunes...; L.A. Grandvaux Barbosa, from <a href='/country/CV'>Cape Verde</a>, <a href='/country/AO'>Angola</a> e <a href='/country/MZ'>Mozambique</a>; J. Espírito Santo, from <a href='/country/ST'>S. Tomé and Príncipe</a>, and <a href='/country/GW'>Guinea-Bissau</a>;";
        assertEquals(longResult, DetailAction.makeCountryLinks(c, longText));
    }
}
