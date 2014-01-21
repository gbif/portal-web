package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.occurrence.Occurrence;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.EndpointType;
import org.gbif.api.vocabulary.EstablishmentMeans;
import org.gbif.api.vocabulary.LifeStage;
import org.gbif.api.vocabulary.OccurrenceValidationRule;
import org.gbif.api.vocabulary.Sex;
import org.gbif.api.vocabulary.TypeStatus;
import org.gbif.dwc.terms.DcTerm;
import org.gbif.dwc.terms.DwcTerm;

import java.util.Date;
import java.util.UUID;
import javax.validation.constraints.NotNull;

/**
 * Creates a new mock Occurrence object, and populates all its possible fields.
 * All verbatim fields (inclufor all 9 DwC groups), validations, and interpreted fields are populated.
 */
public class MockOccurrenceFactory {

  private static Occurrence mockOccurrence;

  /**
   * Empty private constructor.
   */
  private MockOccurrenceFactory() {
  }

  static {
    if (mockOccurrence == null) {
      mockOccurrence = new Occurrence();

      // populate verbatim fields
      populateVerbatimFields();

      // populate interpreted fields
      populateInterpretedFields();

      // populate validations
      populateOccurrenceValidations();
    }
  }

  /**
   * Populate all verbatim occurrence fields, including all verbatim values for all DwC terms.
   */
  private static void populateVerbatimFields() {
    // negative key differentiates this mock occurrence record from real ones
    mockOccurrence.setKey(-1000000000);
    mockOccurrence.setDatasetKey(UUID.fromString("4fa7b334-ce0d-4e88-aaae-2e0c138d049e"));
    mockOccurrence.setPublishingOrgKey(UUID.fromString("e2e717bf-551a-4917-bdc9-4fa0f342c530"));
    mockOccurrence.setPublishingCountry(Country.UNITED_STATES);
    mockOccurrence.setProtocol(EndpointType.DWC_ARCHIVE);
    mockOccurrence.setLastCrawled(new Date());

    // populate fields
    populateVerbatimDwcRecordTerms();
    populateVerbatimDwcOccurrenceTerms();
    populateVerbatimDwcEventTerms();
    populateVerbatimDwcLocationTerms();
    populateVerbatimDwcGeologicalConceptTerms();
    populateVerbatimDwcIdentificationTerms();
    populateVerbatimDwcTaxonTerms();
    populateVerbatimDwcResourceRelationshipTerms();
    populateVerbatimDwcMeasurementOrFactTerms();

    // TODO populate identifiers
    // TODO populate media
    // TODO populate facts
    // TODO populate relations
  }

  /**
   * Populate all interpreted occurrence fields, including the taxonomic classification.
   */
  private static void populateInterpretedFields() {
    mockOccurrence.setBasisOfRecord(BasisOfRecord.HUMAN_OBSERVATION);
    mockOccurrence.setIndividualCount(1);
    mockOccurrence.setSex(Sex.MALE);
    mockOccurrence.setLifeStage(LifeStage.ADULT);
    mockOccurrence.setEstablishmentMeans(EstablishmentMeans.INTRODUCED);
    mockOccurrence.setTaxonKey(2480985);
    mockOccurrence.setKingdomKey(1);
    mockOccurrence.setPhylumKey(44);
    mockOccurrence.setClassKey(212);
    mockOccurrence.setOrderKey(7191407);
    mockOccurrence.setFamilyKey(5240);
    mockOccurrence.setGenusKey(2480984);
    mockOccurrence.setSubgenusKey(109756028);
    mockOccurrence.setSpeciesKey(2480985);
    mockOccurrence.setScientificName("Caracara cheriway (Jacquin, 1784)");
    mockOccurrence.setKingdom("Animalia");
    mockOccurrence.setPhylum("Chordata");
    mockOccurrence.setClazz("Aves");
    mockOccurrence.setOrder("Falconiformes");
    mockOccurrence.setFamily("Falconidae");
    mockOccurrence.setGenus("Caracara");
    mockOccurrence.setSubgenus("Ichthydium (Furficulichthys) Schwank, 1990");
    mockOccurrence.setSpecies("Caracara cheriway (Jacquin, 1784)");
    mockOccurrence.setIdentificationDate(new Date());
    mockOccurrence.setLongitude(-95.86519);
    mockOccurrence.setLatitude(29.91973);
    mockOccurrence.setCoordinateAccurracy(0.00001);
    mockOccurrence.setGeodeticDatum("WGS84");
    mockOccurrence.setAltitude(1000);
    mockOccurrence.setAltitudeAccurracy(1);
    mockOccurrence.setDepth(500);
    mockOccurrence.setDepthAccurracy(1);
    mockOccurrence.setContinent(Continent.NORTH_AMERICA);
    mockOccurrence.setCountry(Country.UNITED_KINGDOM);
    mockOccurrence.setStateProvince("California");
    mockOccurrence.setWaterBody("Lake Aloha");
    mockOccurrence.setYear(2012);
    mockOccurrence.setMonth(1);
    mockOccurrence.setDay(30);
    mockOccurrence.setEventDate(new Date());
    mockOccurrence.setTypeStatus(TypeStatus.HOLOTYPE);
    mockOccurrence.setTypifiedName("Caracara cheriway (Jacquin, 1784)");
    mockOccurrence.setModified(new Date());
    mockOccurrence.setLastInterpreted(new Date());
  }

  /**
   * Populate a map of all Occurrence Validations.
   */
  private static void populateOccurrenceValidations() {
    mockOccurrence.getValidations().put(OccurrenceValidationRule.COORDINATES_OUT_OF_RANGE, true);
    mockOccurrence.getValidations().put(OccurrenceValidationRule.COUNTRY_COORDINATE_MISMATCH, true);
    mockOccurrence.getValidations().put(OccurrenceValidationRule.PRESUMED_NEGATED_LATITUDE, true);
    mockOccurrence.getValidations().put(OccurrenceValidationRule.PRESUMED_NEGATED_LONGITUDE, true);
    mockOccurrence.getValidations().put(OccurrenceValidationRule.PRESUMED_SWAPPED_COORDINATE, true);
    mockOccurrence.getValidations().put(OccurrenceValidationRule.ZERO_COORDINATE, true);
  }

  /**
   * Populate all 19 record level terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_RECORD
   */
  private static void populateVerbatimDwcRecordTerms() {
    mockOccurrence.getFields().put(DcTerm.type, "PhysicalObject");
    mockOccurrence.getFields().put(DcTerm.modified, "1963-03-08T14:07-0600");
    mockOccurrence.getFields().put(DcTerm.language, "en" );
    mockOccurrence.getFields().put(DcTerm.rights, "http://creativecommons.org/licenses/by-sa/3.0/");
    mockOccurrence.getFields().put(DcTerm.rightsHolder, "The Regents of the University of California.");
    mockOccurrence.getFields().put(DcTerm.accessRights, "Not-for-profit use only");
    mockOccurrence.getFields().put(DcTerm.bibliographicCitation, "Ctenomys sociabilis (MVZ 165861)");
    mockOccurrence.getFields().put(DcTerm.references, "http://mvzarctos.berkeley.edu/guid/MVZ:Mamm:165861");
    mockOccurrence.getFields().put(DwcTerm.institutionID, "urn:lsid:biocol.org:institution:34818");
    mockOccurrence.getFields().put(DwcTerm.collectionID, "urn:lsid:biocol.org:col:34818");
    mockOccurrence.getFields().put(DwcTerm.datasetID, "urn:lsid:biocol.org:dataset:123");
    mockOccurrence.getFields().put(DwcTerm.institutionCode, "MVZ");
    mockOccurrence.getFields().put(DwcTerm.collectionCode, "Mammals");
    mockOccurrence.getFields().put(DwcTerm.datasetName, "Grinnell Resurvey Mammals");
    mockOccurrence.getFields().put(DwcTerm.ownerInstitutionCode, "NPS");
    mockOccurrence.getFields().put(DwcTerm.basisOfRecord, "PreservedSpecimen");
    mockOccurrence.getFields().put(DwcTerm.informationWithheld, "Location info not given for endangered species");
    mockOccurrence.getFields().put(DwcTerm.dataGeneralizations, "Coordinates generalized from original coordinates");
    mockOccurrence.getFields().put(DwcTerm.dynamicProperties, "relativeHumidity=28; sampleSizeInKilograms=10");
  }

  /**
   * Populate all occurrence terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_OCCURRENCE
   */
  private static void populateVerbatimDwcOccurrenceTerms() {
    mockOccurrence.getFields().put(DwcTerm.recordedBy, "Jane Smith");
    mockOccurrence.getFields().put(DwcTerm.catalogNumber, "88");
    mockOccurrence.getFields().put(DwcTerm.occurrenceID, "urn:catalog:MVZ:Mammals:88");
  }

  /**
   * Populate all event terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_EVENT
   */
  private static void populateVerbatimDwcEventTerms() {
    mockOccurrence.getFields().put(DwcTerm.year, "2012");
    mockOccurrence.getFields().put(DwcTerm.month, "01");
    mockOccurrence.getFields().put(DwcTerm.day, "30");
    mockOccurrence.getFields().put(DwcTerm.eventDate, "2012-01-30");
  }

  /**
   * Populate all location terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_LOCATION
   */
  private static void populateVerbatimDwcLocationTerms() {
    mockOccurrence.getFields().put(DwcTerm.continent, "North America");
    mockOccurrence.getFields().put(DwcTerm.country, "USA");
    mockOccurrence.getFields().put(DwcTerm.stateProvince, "California");
    mockOccurrence.getFields().put(DwcTerm.locality, "Above Lake Aloha");
  }

  /**
   * Populate all geological concept terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_GEOLOGICALCONTEXT
   */
  private static void populateVerbatimDwcGeologicalConceptTerms() {
    // TODO
  }


  /**
   * Populate all identification terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_IDENTIFICATION
   */
  private static void populateVerbatimDwcIdentificationTerms() {
    mockOccurrence.getFields().put(DwcTerm.identifiedBy, "John Smith");
  }

  /**
   * Populate all taxon terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_TAXON
   */
  private static void populateVerbatimDwcTaxonTerms() {
    mockOccurrence.getFields().put(DwcTerm.scientificName, "Caracara cheriway");
    mockOccurrence.getFields().put(DwcTerm.scientificNameAuthorship, "Jacquin, 1784");
    mockOccurrence.getFields().put(DwcTerm.kingdom, "Animalia");
    mockOccurrence.getFields().put(DwcTerm.phylum, "Chordata");
    mockOccurrence.getFields().put(DwcTerm.class_, "Aves");
    mockOccurrence.getFields().put(DwcTerm.order, "Falconiformes");
    mockOccurrence.getFields().put(DwcTerm.family, "Falconidae");
    mockOccurrence.getFields().put(DwcTerm.genus, "Caracara");
    mockOccurrence.getFields().put(DwcTerm.specificEpithet, "cheriway");
  }

  /**
   * Populate all resource relationship terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_RESOURCERELATIONSHIP
   */
  private static void populateVerbatimDwcResourceRelationshipTerms() {
    // TODO
  }

  /**
   * Populate all measurement or fact terms with mock values.
   *
   * @see org.gbif.dwc.terms.DwcTerm#GROUP_MEASUREMENTORFACT
   */
  private static void populateVerbatimDwcMeasurementOrFactTerms() {
    // TODO
  }

  /**
   * Return the populated mock Occurrence object.
   *
   * @return the populated mock Occurrence object
   */
  @NotNull
  public static Occurrence getMockOccurrence() {
    return mockOccurrence;
  }

  public static void setMockOccurrence(Occurrence mockOccurrence) {
    MockOccurrenceFactory.mockOccurrence = mockOccurrence;
  }
}
