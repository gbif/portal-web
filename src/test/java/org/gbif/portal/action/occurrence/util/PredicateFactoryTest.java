package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.occurrence.predicate.ConjunctionPredicate;
import org.gbif.api.model.occurrence.predicate.DisjunctionPredicate;
import org.gbif.api.model.occurrence.predicate.EqualsPredicate;
import org.gbif.api.model.occurrence.predicate.GreaterThanOrEqualsPredicate;
import org.gbif.api.model.occurrence.predicate.LessThanOrEqualsPredicate;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.predicate.SimplePredicate;
import org.gbif.api.model.occurrence.predicate.WithinPredicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.vocabulary.Country;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

import com.google.common.collect.Maps;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class PredicateFactoryTest {

  Random rnd = new Random();

  @Test
  public void assertAllParametersAreConvertible() throws Exception {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = Maps.newHashMap();

    for (OccurrenceSearchParameter p : OccurrenceSearchParameter.values()) {
      params.put(p.name(), new String[] {randomValue(p)});
    }

    Predicate p = pf.build(params);
    assertEquals(OccurrenceSearchParameter.values().length, ((ConjunctionPredicate) p).getPredicates().size());
  }


  @Test
  public void testBuild() {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = new HashMap<String, String[]>();
    params.put("BASIS_OF_RECORD", new String[] {"PRESERVED_SPECIMEN"});
    Predicate p = pf.build(params);

    assertTrue(p instanceof EqualsPredicate);
    EqualsPredicate eq = (EqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.BASIS_OF_RECORD, eq.getKey());
    assertEquals("PRESERVED_SPECIMEN", eq.getValue());

    // add a second country to check an OR is built
    params.put("BASIS_OF_RECORD", new String[] {"OBSERVATION", "PRESERVED_SPECIMEN"});
    p = pf.build(params);
    assertTrue(p instanceof DisjunctionPredicate);
    DisjunctionPredicate dq = (DisjunctionPredicate) p;
    assertEquals(2, dq.getPredicates().size());
    Iterator<Predicate> iter = dq.getPredicates().iterator();
    p = iter.next();
    assertTrue(p instanceof EqualsPredicate);
    eq = (EqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.BASIS_OF_RECORD, eq.getKey());
    assertEquals("OBSERVATION", eq.getValue());
    p = iter.next();
    assertTrue(p instanceof EqualsPredicate);
    eq = (EqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.BASIS_OF_RECORD, eq.getKey());
    assertEquals("PRESERVED_SPECIMEN", eq.getValue());

    // add a third to check an AND is built
    params.put("LATITUDE", new String[] {"10.07, *"}); // greater than or equals
    p = pf.build(params);
    assertTrue(p instanceof ConjunctionPredicate);
    ConjunctionPredicate cq = (ConjunctionPredicate) p;
    assertEquals(2, cq.getPredicates().size());
    iter = cq.getPredicates().iterator();
    p = iter.next();
    assertTrue(p instanceof DisjunctionPredicate);
    p = iter.next();
    assertTrue(p instanceof GreaterThanOrEqualsPredicate); // the OR'ed scientific names (tested above)
    GreaterThanOrEqualsPredicate gp = (GreaterThanOrEqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.LATITUDE, gp.getKey());
    assertEquals("10.07", gp.getValue());
  }

  @Test
  public void testIsoDate() throws Exception {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = Maps.newHashMap();

    params.put("DATE", new String[] {"1989-09-11, 1991"});
    Predicate p = pf.build(params);
    assertTrue(p instanceof ConjunctionPredicate);
    ConjunctionPredicate and = (ConjunctionPredicate) p;

    assertEquals(2, and.getPredicates().size());
    Iterator<Predicate> iter = and.getPredicates().iterator();

    p = iter.next();
    GreaterThanOrEqualsPredicate gt = (GreaterThanOrEqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.DATE, gt.getKey());
    assertEquals("1989-09-11", gt.getValue());

    p = iter.next();
    LessThanOrEqualsPredicate lt = (LessThanOrEqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.DATE, lt.getKey());
    assertEquals("1991-12-31", lt.getValue());
  }

  @Test
  public void testIsoDateUnbound() throws Exception {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = Maps.newHashMap();

    params.put("DATE", new String[] {"*,1991"});
    Predicate p = pf.build(params);

    LessThanOrEqualsPredicate lt = (LessThanOrEqualsPredicate) p;
    assertEquals(OccurrenceSearchParameter.DATE, lt.getKey());
    assertEquals("1991-12-31", lt.getValue());
  }

  @Test
  public void testOR() {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = Maps.newHashMap();

    params.put("CATALOG_NUMBER", new String[] {"A", "B"});// equals

    Predicate p = pf.build(params);
    assertTrue(p instanceof DisjunctionPredicate);
  }

  @Test
  public void testPolygon() throws Exception {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = Maps.newHashMap();

    params.put("GEOMETRY", new String[] {"30 10,10 20,20 40,40 40,30 10"});// equals

    Predicate p = pf.build(params);
    assertTrue(p instanceof WithinPredicate);
    WithinPredicate within = (WithinPredicate) p;
    assertEquals("POLYGON((30 10,10 20,20 40,40 40,30 10))", within.getGeometry());
  }

  @Test
  public void testRange() {
    PredicateFactory pf = new PredicateFactory();
    Map<String, String[]> params = Maps.newHashMap();

    params.put("YEAR", new String[] {"1900", "1800,1840", "*, 1700", "2000 , *"});

    Predicate p = pf.build(params);
    assertTrue(p instanceof DisjunctionPredicate);
    DisjunctionPredicate or = (DisjunctionPredicate) p;
    assertEquals(4, or.getPredicates().size());
    Iterator<Predicate> iter = or.getPredicates().iterator();

    p = iter.next();
    assertSimplePredicate(p, EqualsPredicate.class, "1900", OccurrenceSearchParameter.YEAR);

    p = iter.next();
    assertTrue(p instanceof ConjunctionPredicate);
    ConjunctionPredicate and = (ConjunctionPredicate) p;
    assertEquals(2, and.getPredicates().size());
    Iterator<Predicate> andIter = and.getPredicates().iterator();
    assertSimplePredicate(andIter.next(), GreaterThanOrEqualsPredicate.class, "1800", OccurrenceSearchParameter.YEAR);
    assertSimplePredicate(andIter.next(), LessThanOrEqualsPredicate.class, "1840", OccurrenceSearchParameter.YEAR);

    p = iter.next();
    assertSimplePredicate(p, LessThanOrEqualsPredicate.class, "1700", OccurrenceSearchParameter.YEAR);

    p = iter.next();
    assertSimplePredicate(p, GreaterThanOrEqualsPredicate.class, "2000", OccurrenceSearchParameter.YEAR);
  }

  private void assertSimplePredicate(Predicate p, Class<? extends SimplePredicate> expectedClass, String expectedValue,
    OccurrenceSearchParameter expectedParam) {
    assertEquals(expectedClass, p.getClass());
    SimplePredicate sp = (SimplePredicate) p;
    assertEquals(expectedParam, sp.getKey());
    assertEquals(expectedValue, sp.getValue());
  }

  private String randomValue(OccurrenceSearchParameter p) {
    if (OccurrenceSearchParameter.COUNTRY == p) {
      return Country.SPAIN.getIso2LetterCode();

    } else if (OccurrenceSearchParameter.GEOMETRY == p) {
      return "30.12 10, 10 20, 20 40, 40 40, 30.12 10";

    } else if (UUID.class.isAssignableFrom(p.type())) {
      return UUID.randomUUID().toString();

    } else if (Boolean.class.isAssignableFrom(p.type())) {
      return "true";

    } else if (OccurrenceSearchParameter.MONTH == p) {
      return String.format("%02d", 1 + rnd.nextInt(11));

    } else if (OccurrenceSearchParameter.LONGITUDE == p) {
      return Integer.toString(rnd.nextInt(180));

    } else if (OccurrenceSearchParameter.LATITUDE == p) {
      return Integer.toString(rnd.nextInt(90));

    } else if (OccurrenceSearchParameter.COUNTRY == p || OccurrenceSearchParameter.PUBLISHING_COUNTRY == p) {
      return Country.AFGHANISTAN.getIso2LetterCode();

    } else if (Enum.class.isAssignableFrom(p.type())) {
      Class<? extends Enum<?>> vocab = (Class<? extends Enum<?>>) p.type();
      return vocab.getEnumConstants()[0].name();
    }

    return String.format("%04d", 1 + rnd.nextInt(2012));
  }
}
