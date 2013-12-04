package org.gbif.portal.model;

public class CountryMetrics {

  private final long occurrenceDatasets;
  private final long occurrenceRecords;
  private final long checklistDatasets;
  private final long checklistRecords;
  private final long externalDatasets;
  private final int institutions;
  private final int countries;

  public CountryMetrics(long occurrenceDatasets, long occurrenceRecords, long checklistDatasets, long checklistRecords,
    long externalDatasets, int institutions, int countries) {
    this.occurrenceDatasets = occurrenceDatasets;
    this.occurrenceRecords = occurrenceRecords;
    this.checklistDatasets = checklistDatasets;
    this.checklistRecords = checklistRecords;
    this.externalDatasets = externalDatasets;
    this.institutions = institutions;
    this.countries = countries;
  }

  public long getOccurrenceDatasets() {
    return occurrenceDatasets;
  }

  public long getOccurrenceRecords() {
    return occurrenceRecords;
  }

  public long getChecklistDatasets() {
    return checklistDatasets;
  }

  public long getChecklistRecords() {
    return checklistRecords;
  }

  public long getExternalDatasets() {
    return externalDatasets;
  }

  public int getInstitutions() {
    return institutions;
  }

  public int getCountries() {
    return countries;
  }
}