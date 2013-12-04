package org.gbif.portal.model;

import java.util.Collection;

import com.google.common.base.Objects;
import com.google.common.collect.ComparisonChain;

/**
 * Simple wrapper that adds a record count and a geo reference count to any object instance.
 */
public class CountWrapper<T> implements Comparable<CountWrapper<?>> {

  private final T obj;
  private long count;
  private long geoCount;

  public CountWrapper(T obj) {
    this.obj = obj;
  }

  public CountWrapper(T obj, long count) {
    this.obj = obj;
    this.count = count;
  }

  public CountWrapper(T obj, long count, long geoCount) {
    this.obj = obj;
    this.count = count;
    this.geoCount = geoCount;
  }

  /**
   * @param values of counts
   *
   * @return the sum of all count values
   */
  public static <T> long sum(Collection<CountWrapper<T>> values) {
    long total = 0;
    for (CountWrapper<?> d : values) {
      total += d.getCount();
    }
    return total;
  }

  public long getCount() {
    return count;
  }

  public void setCount(long count) {
    this.count = count;
  }

  public long getGeoCount() {
    return geoCount;
  }

  public void setGeoCount(long geoCount) {
    this.geoCount = geoCount;
  }

  public T getObj() {
    return obj;
  }

  public void increaseCount(long value) {
    count += value;
  }

  @Override
  public int compareTo(CountWrapper<?> that) {
    return ComparisonChain.start()
      .compare(this.count, that.count)
      .compare(this.geoCount, that.geoCount)
      .compare(this.obj.hashCode(), that.obj.hashCode())
      .result();
  }

  @Override
  public boolean equals(Object o) {
    if (o instanceof CountWrapper) {
      CountWrapper that = (CountWrapper) o;
      return Objects.equal(this.obj, that.obj)
             && Objects.equal(this.count, that.count)
             && Objects.equal(this.geoCount, that.geoCount);
    }
    return false;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(obj, count, geoCount);
  }
}
