package org.gbif.portal.action.dataset;

import org.gbif.api.model.registry.Contact;
import org.gbif.api.vocabulary.ContactType;
import org.gbif.portal.action.node.NodeAction;

import java.util.Collections;
import java.util.List;

import com.google.common.collect.Lists;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class NodeContactOrderTest {

  int nextContactId = 1;

  @Test
  public void test() {
    List<Contact> contacts = Lists.newArrayList(
      build(ContactType.AUTHOR, "Pia", "Possible"),
      build(ContactType.ADDITIONAL_DELEGATE, "Pia", "Possible"),
      build(ContactType.NODE_STAFF, "Karl", "Orff"),
      build(ContactType.NODE_STAFF, "Iggy", "Pop"),
      build(ContactType.SYSTEM_ADMINISTRATOR, "Cip", "Munk"),
      build(ContactType.NODE_MANAGER, "Dag", "Dig"),
      build(ContactType.REGIONAL_NODE_REPRESENTATIVE, "Retro", "Mayer"),
      build(null, null, null),
      build(ContactType.HEAD_OF_DELEGATION, "Tip", "Top")
      );

    Collections.sort(contacts, new NodeAction.NodeContactOrder());

    for (Contact c : contacts) {
      System.out.println(c);
    }

    assertEquals((Integer) 9, contacts.get(0).getKey());
    assertEquals((Integer) 7, contacts.get(1).getKey());
    assertEquals((Integer) 6, contacts.get(2).getKey());
    assertEquals((Integer) 4, contacts.get(3).getKey());
    assertEquals((Integer) 3, contacts.get(4).getKey());
    assertEquals((Integer) 1, contacts.get(5).getKey());
    assertEquals((Integer) 5, contacts.get(6).getKey());
    assertEquals((Integer) 2, contacts.get(7).getKey());
    assertEquals((Integer) 8, contacts.get(8).getKey());
  }


  private Contact build(ContactType type, String first, String last) {
    Contact c = new Contact();
    c.setType(type);
    c.setFirstName(first);
    c.setLastName(last);
    c.setKey(nextContactId++);
    return c;
  }
}
